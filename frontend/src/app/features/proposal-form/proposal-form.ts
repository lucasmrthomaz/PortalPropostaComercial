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
import { MatIconModule } from '@angular/material/icon';

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
    MatSnackBarModule,
    MatIconModule
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

    this.initForm();
    this.loadProposalTypes();
    this.loadClients();
  }

  loadProposalTypes(): void {
    this.proposalTypeService.list().subscribe({
      next: (types) => {
        this.proposalTypes = types;
        // Se estiver editando, força o gatilho da mudança de tipo para carregar os valores existentes
        if (this.isEditMode && this.data) {
          this.onTipoChange(this.data.tipo, this.data.dados_especificos);
        } else if (this.proposalForm.get('tipo')?.value) {
          this.onTipoChange(this.proposalForm.get('tipo')?.value);
        }
      },
      error: (err) => {
        console.error('Erro ao carregar tipos de proposta', err);
        if (this.proposalForm.get('tipo')?.value) {
          this.onTipoChange(this.proposalForm.get('tipo')?.value);
        }
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
      dados_especificos: this.fb.group({
        // Imobiliaria
        endereco_imovel: [''],
        tipo_imovel: ['Casa'],
        area_m2: [''],
        // Auto
        marca: [''],
        modelo: [''],
        ano: [''],
        placa: [''],
        // CompraVenda
        itens: [''],
        condicoes_pagamento: [''],
        // Attachments
        foto: [''],
        anexo: [''],
        nome_anexo: ['']
      })
    });

    // Monitora mudança do tipo de proposta para atualizar os campos específicos
    this.proposalForm.get('tipo')?.valueChanges.subscribe((tipo: ProposalType) => {
      this.onTipoChange(tipo);
    });
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
    
    const standardKeys = [
      'endereco_imovel', 'tipo_imovel', 'area_m2',
      'marca', 'modelo', 'ano', 'placa',
      'itens', 'condicoes_pagamento',
      'foto', 'anexo', 'nome_anexo'
    ];

    // Limpa validadores e valores de todos os controles padrão
    standardKeys.forEach(key => {
      const control = specGroup.get(key);
      if (control) {
        control.clearValidators();
        let defaultVal = '';
        if (key === 'tipo_imovel') defaultVal = 'Casa';
        control.setValue(defaultVal);
      }
    });

    // Remove qualquer outro controle dinâmico/customizado anterior
    Object.keys(specGroup.controls).forEach(key => {
      if (!standardKeys.includes(key)) {
        specGroup.removeControl(key);
      }
    });

    if (typeof values === 'string') {
      try {
        values = JSON.parse(values);
      } catch (e) {
        // Ignora
      }
    }

    if (tipo === 'Imobiliaria') {
      specGroup.get('endereco_imovel')?.setValidators(Validators.required);
      specGroup.get('tipo_imovel')?.setValidators(Validators.required);
      specGroup.get('area_m2')?.setValidators([Validators.required, Validators.min(1)]);
      
      if (values) {
        specGroup.patchValue({
          endereco_imovel: values.endereco_imovel || '',
          tipo_imovel: values.tipo_imovel || 'Casa',
          area_m2: values.area_m2 || '',
          foto: values.foto || ''
        });
      }
    } else if (tipo === 'Auto') {
      specGroup.get('marca')?.setValidators(Validators.required);
      specGroup.get('modelo')?.setValidators(Validators.required);
      specGroup.get('ano')?.setValidators([Validators.required, Validators.min(1900)]);
      specGroup.get('placa')?.setValidators(Validators.required);
      
      if (values) {
        specGroup.patchValue({
          marca: values.marca || '',
          modelo: values.modelo || '',
          ano: values.ano || '',
          placa: values.placa || '',
          foto: values.foto || ''
        });
      }
    } else if (tipo === 'CompraVenda') {
      specGroup.get('itens')?.setValidators(Validators.required);
      specGroup.get('condicoes_pagamento')?.setValidators(Validators.required);
      
      if (values) {
        specGroup.patchValue({
          itens: values.itens || '',
          condicoes_pagamento: values.condicoes_pagamento || '',
          foto: values.foto || '',
          anexo: values.anexo || '',
          nome_anexo: values.nome_anexo || ''
        });
      }
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

    // Atualiza a validade e o estado de todos os controles
    Object.keys(specGroup.controls).forEach(key => {
      specGroup.get(key)?.updateValueAndValidity();
    });
    specGroup.updateValueAndValidity();
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

  onPhotoSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files[0]) {
      const file = input.files[0];
      if (!file.type.startsWith('image/')) {
        this.snackBar.open('Por favor, selecione apenas arquivos de imagem.', 'Fechar', { duration: 3000 });
        return;
      }

      if (file.size > 10 * 1024 * 1024) {
        this.snackBar.open('A imagem é muito grande. O limite máximo é de 10MB.', 'Fechar', { duration: 3000 });
        return;
      }

      const reader = new FileReader();
      reader.onload = () => {
        const specGroup = this.proposalForm.get('dados_especificos') as FormGroup;
        specGroup.get('foto')?.setValue(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  }

  removePhoto(): void {
    const specGroup = this.proposalForm.get('dados_especificos') as FormGroup;
    specGroup.get('foto')?.setValue('');
  }

  onAttachmentSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files[0]) {
      const file = input.files[0];
      
      const maxSize = 8 * 1024 * 1024; // 8MB
      if (file.size > maxSize) {
        this.snackBar.open('O arquivo excede o limite máximo permitido de 8MB.', 'Fechar', { duration: 5000 });
        input.value = '';
        return;
      }

      const reader = new FileReader();
      reader.onload = () => {
        const specGroup = this.proposalForm.get('dados_especificos') as FormGroup;
        specGroup.get('anexo')?.setValue(reader.result as string);
        specGroup.get('nome_anexo')?.setValue(file.name);
      };
      reader.readAsDataURL(file);
    }
  }

  removeAttachment(): void {
    const specGroup = this.proposalForm.get('dados_especificos') as FormGroup;
    specGroup.get('anexo')?.setValue('');
    specGroup.get('nome_anexo')?.setValue('');
  }

  onSubmit(): void {
    if (this.proposalForm.invalid) return;

    const formVal = this.proposalForm.value;
    const tipo = formVal.tipo;
    const rawDados = formVal.dados_especificos;
    let filteredDados: any = {};

    if (tipo === 'Imobiliaria') {
      filteredDados = {
        endereco_imovel: rawDados.endereco_imovel,
        tipo_imovel: rawDados.tipo_imovel,
        area_m2: rawDados.area_m2,
        foto: rawDados.foto
      };
    } else if (tipo === 'Auto') {
      filteredDados = {
        marca: rawDados.marca,
        modelo: rawDados.modelo,
        ano: rawDados.ano,
        placa: rawDados.placa,
        foto: rawDados.foto
      };
    } else if (tipo === 'CompraVenda') {
      filteredDados = {
        itens: rawDados.itens,
        condicoes_pagamento: rawDados.condicoes_pagamento,
        foto: rawDados.foto,
        anexo: rawDados.anexo,
        nome_anexo: rawDados.nome_anexo
      };
    } else {
      const fields = this.getSelectedTypeFields();
      fields.forEach(c => {
        filteredDados[c.chave] = rawDados[c.chave];
      });
    }

    const proposalData: Proposta = {
      cliente_id: formVal.cliente_id,
      tipo: formVal.tipo,
      valor: Number(formVal.valor),
      status: formVal.status,
      descricao: formVal.descricao,
      dados_especificos: JSON.stringify(filteredDados), // Convertido para string JSON filtrado para enviar ao backend
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
