import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { CompanyService } from '../../core/services/company.service';
import { Empresa } from '../../core/models/company.model';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';

@Component({
  selector: 'app-company-form',
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatSlideToggleModule,
    MatSnackBarModule
  ],
  templateUrl: './company-form.html',
  styleUrl: './company-form.scss'
})
export class CompanyForm implements OnInit {
  private fb = inject(FormBuilder);
  private companyService = inject(CompanyService);
  private snackBar = inject(MatSnackBar);
  private dialogRef = inject(MatDialogRef<CompanyForm>);
  private data = inject<Empresa>(MAT_DIALOG_DATA);

  companyForm!: FormGroup;
  isEditMode = false;

  ngOnInit(): void {
    this.isEditMode = !!this.data?.id;
    this.initForm();
  }

  initForm(): void {
    this.companyForm = this.fb.group({
      nome: [this.data?.nome || '', [Validators.required]],
      cnpj: [this.data?.cnpj || '', [Validators.required]],
      email: [this.data?.email || '', [Validators.required, Validators.email]],
      telefone: [this.data?.telefone || ''],
      responsavel_nome: [this.data?.responsavel_nome || '', [Validators.required]],
      responsavel_email: [this.data?.responsavel_email || '', [Validators.email]],
      responsavel_telefone: [this.data?.responsavel_telefone || ''],
      ativo: [this.data?.ativo !== false]
    });
  }

  onSubmit(): void {
    if (this.companyForm.invalid) return;

    const companyData: Empresa = {
      ...this.companyForm.value,
      id: this.isEditMode ? this.data.id : undefined
    };

    if (this.isEditMode && this.data.id) {
      this.companyService.update(this.data.id, companyData).subscribe({
        next: () => {
          this.snackBar.open('Empresa parceira atualizada!', 'Fechar', { duration: 3000 });
          this.dialogRef.close(true);
        },
        error: (err) => {
          this.snackBar.open(err.error?.error || 'Erro ao atualizar empresa.', 'Fechar', { duration: 5000 });
        }
      });
    } else {
      this.companyService.create(companyData).subscribe({
        next: () => {
          this.snackBar.open('Empresa parceira cadastrada!', 'Fechar', { duration: 3000 });
          this.dialogRef.close(true);
        },
        error: (err) => {
          this.snackBar.open(err.error?.error || 'Erro ao cadastrar empresa.', 'Fechar', { duration: 5000 });
        }
      });
    }
  }
}
