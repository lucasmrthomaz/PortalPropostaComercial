import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { ClientService } from '../../core/services/client.service';
import { ProposalService } from '../../core/services/proposal.service';
import { ProposalTypeService } from '../../core/services/proposal-type.service';
import { Cliente } from '../../core/models/client.model';
import { Proposta, ProposalType } from '../../core/models/proposal.model';
import { TipoProposta, CampoTipoProposta } from '../../core/models/proposal-type.model';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';

@Component({
  selector: 'app-proposal-form',
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatButtonModule,
    MatSnackBarModule
  ],
  templateUrl: './proposal-form.html',
  styleUrl: './proposal-form.scss'
})
export class ProposalForm implements OnInit {
  private fb = inject(FormBuilder);
  private clientService = inject(ClientService);
  private proposalService = inject(ProposalService);
  private proposalTypeService = inject(ProposalTypeService);
  private snackBar = inject(MatSnackBar);
  private dialogRef = inject(MatDialogRef<ProposalForm>);
  private data = inject<any>(MAT_DIALOG_DATA);

  proposalForm!: FormGroup;
  clients: Cliente[] = [];
  proposalTypes: TipoProposta[] = [];
  isEditMode = false;
  presetClientId: string | null = null;
  presetClientName: string | null = null;

  ngOnInit(): void {
    // A data pode ser uma Proposta completa (Edição) ou um objeto com { cliente_id, cliente_nome } (Nova proposta para cliente específico)
    this.isEditMode = !!this.data?.id;
    
    if (!this.isEditMode && this.data?.cliente_id) {
      this.presetClientId = this.data.cliente_id;
      this.presetClientName = this.data.cliente_nome;
    }

    this.loadProposalTypes();
    this.loadClients();
  }

  loadProposalTypes(): void {
    this.proposalTypeService.list().subscribe({
      next: (types) => {
        this.proposalTypes = types;
        this.initForm();
      },
      error: (err) => {
        console.error('Erro ao carregar tipos de proposta', err);
        this.initForm();
      }
    });
  }

  initForm(): void {
    this.proposalForm = this.fb.group({
      cliente_id: [this.presetClientId || this.data?.cliente_id || '', Validators.required],
      tipo: [this.data?.tipo || '', Validators.required],
      valor: [this.data?.valor || '', [Validators.required, Validators.min(0.01)]],
      status: [this.data?.status || 'Pendente', Validators.required],
      descricao: [this.data?.descricao || ''],
      dados_especificos: this.fb.group({})
    });

    // Monitora mudança do tipo de proposta para atualizar os campos específicos
    this.proposalForm.get('tipo')?.valueChanges.subscribe((tipo: ProposalType) => {
      this.onTipoChange(tipo);
    });

    // Se estiver editando, força o gatilho da mudança de tipo para carregar os valores existentes
    if (this.isEditMode && this.data) {
      this.onTipoChange(this.data.tipo, this.data.dados_especificos);
    }
  }

  loadClients(): void {
    this.clientService.list().subscribe({
      next: (res) => {
        this.clients = res;
      },
      error: (err) => {
        console.error('Erro ao carregar clientes', err);
      }
    });
  }

  onTipoChange(tipo: ProposalType, values?: any): void {
    const specGroup = this.proposalForm.get('dados_especificos') as FormGroup;
    
    // Limpa controles anteriores
    Object.keys(specGroup.controls).forEach(key => specGroup.removeControl(key));

    if (typeof values === 'string') {
      try {
        values = JSON.parse(values);
      } catch (e) {
        // Ignora
      }
    }

    if (tipo === 'Imobiliaria') {
      specGroup.addControl('endereco_imovel', this.fb.control(values?.endereco_imovel || '', Validators.required));
      specGroup.addControl('tipo_imovel', this.fb.control(values?.tipo_imovel || 'Casa', Validators.required));
      specGroup.addControl('area_m2', this.fb.control(values?.area_m2 || '', [Validators.required, Validators.min(1)]));
    } else if (tipo === 'Auto') {
      specGroup.addControl('marca', this.fb.control(values?.marca || '', Validators.required));
      specGroup.addControl('modelo', this.fb.control(values?.modelo || '', Validators.required));
      specGroup.addControl('ano', this.fb.control(values?.ano || '', [Validators.required, Validators.min(1900)]));
      specGroup.addControl('placa', this.fb.control(values?.placa || '', Validators.required));
    } else if (tipo === 'CompraVenda') {
      specGroup.addControl('itens', this.fb.control(values?.itens || '', Validators.required));
      specGroup.addControl('condicoes_pagamento', this.fb.control(values?.condicoes_pagamento || '', Validators.required));
    } else {
      const foundType = this.proposalTypes.find(t => t.chave === tipo);
      if (foundType && foundType.campos) {
        let fieldsList: CampoTipoProposta[] = [];
        if (typeof foundType.campos === 'string') {
          try {
            fieldsList = JSON.parse(foundType.campos);
          } catch (e) {
            console.error('Erro ao converter campos', e);
          }
        } else {
          fieldsList = foundType.campos;
        }

        fieldsList.forEach(c => {
          const validators = [];
          if (c.obrigatorio) {
            validators.push(Validators.required);
          }
          let initialVal = values?.[c.chave];
          if (initialVal === undefined) {
            initialVal = c.tipo === 'boolean' ? false : '';
          }
          specGroup.addControl(c.chave, this.fb.control(initialVal, validators));
        });
      }
    }
  }

  isDynamicType(tipo: string): boolean {
    if (!tipo) return false;
    return tipo !== 'Imobiliaria' && tipo !== 'Auto' && tipo !== 'CompraVenda';
  }

  getSelectedTypeLabel(): string {
    const tipo = this.proposalForm?.get('tipo')?.value;
    if (!tipo) return '';
    const found = this.proposalTypes.find(t => t.chave === tipo);
    return found ? found.nome : tipo;
  }

  getSelectedTypeFields(): CampoTipoProposta[] {
    const tipo = this.proposalForm?.get('tipo')?.value;
    if (!tipo) return [];
    const found = this.proposalTypes.find(t => t.chave === tipo);
    if (!found || !found.campos) return [];

    if (typeof found.campos === 'string') {
      try {
        return JSON.parse(found.campos);
      } catch (e) {
        return [];
      }
    }
    return found.campos;
  }

  onSubmit(): void {
    if (this.proposalForm.invalid) return;

    const formVal = this.proposalForm.value;
    const proposalData: Proposta = {
      cliente_id: formVal.cliente_id,
      tipo: formVal.tipo,
      valor: Number(formVal.valor),
      status: formVal.status,
      descricao: formVal.descricao,
      dados_especificos: JSON.stringify(formVal.dados_especificos), // Convertido para string JSON para enviar ao backend
      id: this.isEditMode ? this.data.id : undefined
    };

    if (this.isEditMode && this.data.id) {
      this.proposalService.update(this.data.id, proposalData).subscribe({
        next: () => {
          this.snackBar.open('Proposta atualizada com sucesso!', 'Fechar', { duration: 3000 });
          this.dialogRef.close(true);
        },
        error: (err) => {
          this.snackBar.open(err.error?.error || 'Erro ao atualizar proposta.', 'Fechar', { duration: 5000 });
        }
      });
    } else {
      this.proposalService.create(proposalData).subscribe({
        next: () => {
          this.snackBar.open('Proposta criada com sucesso!', 'Fechar', { duration: 3000 });
          this.dialogRef.close(true);
        },
        error: (err) => {
          this.snackBar.open(err.error?.error || 'Erro ao criar proposta.', 'Fechar', { duration: 5000 });
        }
      });
    }
  }
}
