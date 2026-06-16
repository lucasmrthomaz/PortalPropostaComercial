import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, FormArray, Validators } from '@angular/forms';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDividerModule } from '@angular/material/divider';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { TipoProposta, CampoTipoProposta } from '../../../core/models/proposal-type.model';

@Component({
  selector: 'app-proposal-type-dialog',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatButtonModule,
    MatIconModule,
    MatDividerModule,
    MatSnackBarModule
  ],
  templateUrl: './proposal-type-dialog.html',
  styleUrl: './proposal-type-dialog.scss'
})
export class ProposalTypeDialog implements OnInit {
  private fb = inject(FormBuilder);
  private dialogRef = inject(MatDialogRef<ProposalTypeDialog>);
  private snackBar = inject(MatSnackBar);
  protected data = inject<TipoProposta | null>(MAT_DIALOG_DATA);

  typeForm!: FormGroup;
  isEditMode = false;
  isLegacy = false;

  ngOnInit(): void {
    this.isEditMode = !!this.data?.id;
    this.isLegacy = this.isEditMode && (this.data?.chave === 'Imobiliaria' || this.data?.chave === 'Auto' || this.data?.chave === 'CompraVenda');
    this.initForm();
  }

  initForm(): void {
    this.typeForm = this.fb.group({
      nome: [this.data?.nome || '', Validators.required],
      chave: [
        this.data?.chave || '',
        [Validators.required, Validators.pattern(/^[a-zA-Z0-9]+$/)]
      ],
      campos: this.fb.array([])
    });

    if (this.isEditMode) {
      // Disable key editing in edit mode to prevent breaking relations
      this.typeForm.get('chave')?.disable();
      
      if (this.data?.campos) {
        // Parse fields if they are string/object
        let fieldsList: CampoTipoProposta[] = [];
        if (typeof this.data.campos === 'string') {
          try {
            fieldsList = JSON.parse(this.data.campos);
          } catch (e) {
            console.error('Erro ao converter campos', e);
          }
        } else {
          fieldsList = this.data.campos;
        }

        fieldsList.forEach(c => this.addField(c));
      }
    }

    // Auto-generate key from name for new proposal types
    if (!this.isEditMode) {
      this.typeForm.get('nome')?.valueChanges.subscribe(name => {
        const keyControl = this.typeForm.get('chave');
        if (keyControl && !keyControl.dirty) {
          const generatedKey = this.slugify(name);
          keyControl.setValue(generatedKey, { emitEvent: false });
        }
      });
    }
  }

  get campos(): FormArray {
    return this.typeForm.get('campos') as FormArray;
  }

  createFieldGroup(field?: CampoTipoProposta): FormGroup {
    const group = this.fb.group({
      nome: [field?.nome || '', Validators.required],
      chave: [field?.chave || '', [Validators.required, Validators.pattern(/^[a-z0-9_]+$/)]],
      tipo: [field?.tipo || 'text', Validators.required],
      obrigatorio: [field?.obrigatorio !== undefined ? field.obrigatorio : true, Validators.required]
    });

    // Auto-generate field key from field name
    group.get('nome')?.valueChanges.subscribe(nome => {
      const keyCtrl = group.get('chave');
      if (keyCtrl && !keyCtrl.dirty) {
        keyCtrl.setValue(this.slugifyField(nome || ''), { emitEvent: false });
      }
    });

    if (this.isLegacy) {
      group.disable(); // Disable editing fields for legacy types
    }

    return group;
  }

  addField(field?: CampoTipoProposta): void {
    this.campos.push(this.createFieldGroup(field));
  }

  removeField(index: number): void {
    if (this.isLegacy) return;
    this.campos.removeAt(index);
  }

  slugify(text: string): string {
    return text
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '') // remove acentos
      .replace(/[^a-zA-Z0-9]/g, ''); // remove tudo exceto letras e numeros
  }

  slugifyField(text: string): string {
    return text
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '') // remove acentos
      .toLowerCase()
      .replace(/[^a-z0-9]/g, '_') // substitui nao-alfanumericos por _
      .replace(/_+/g, '_') // substitui multiplos _ por um unico
      .replace(/^_+|_+$/g, ''); // remove _ no inicio e fim
  }

  onSubmit(): void {
    if (this.typeForm.invalid) return;

    // Get raw value because disabled fields are excluded by this.typeForm.value
    const formValue = this.typeForm.getRawValue();

    const proposalTypeData: TipoProposta = {
      nome: formValue.nome,
      chave: formValue.chave,
      campos: formValue.campos,
      id: this.isEditMode ? this.data?.id : undefined
    };

    this.dialogRef.close(proposalTypeData);
  }
}
