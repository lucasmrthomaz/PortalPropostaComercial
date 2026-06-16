import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { ClientService } from '../../core/services/client.service';
import { Cliente } from '../../core/models/client.model';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';

@Component({
  selector: 'app-client-form',
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatSnackBarModule
  ],
  templateUrl: './client-form.html',
  styleUrl: './client-form.scss'
})
export class ClientForm implements OnInit {
  private fb = inject(FormBuilder);
  private clientService = inject(ClientService);
  private snackBar = inject(MatSnackBar);
  private dialogRef = inject(MatDialogRef<ClientForm>);
  private data = inject<Cliente>(MAT_DIALOG_DATA);

  clientForm!: FormGroup;
  isEditMode = false;

  ngOnInit(): void {
    this.isEditMode = !!this.data?.id;
    this.initForm();
  }

  initForm(): void {
    this.clientForm = this.fb.group({
      nome: [this.data?.nome || '', [Validators.required, Validators.minLength(3)]],
      cpf_cnpj: [this.data?.cpf_cnpj || '', [Validators.required]],
      email: [this.data?.email || '', [Validators.required, Validators.email]],
      telefone: [this.data?.telefone || ''],
      endereco: [this.data?.endereco || '']
    });
  }

  onSubmit(): void {
    if (this.clientForm.invalid) return;

    const clientData: Cliente = {
      ...this.clientForm.value,
      // Se for edição, mantém o id
      id: this.isEditMode ? this.data.id : undefined
    };

    if (this.isEditMode && this.data.id) {
      this.clientService.update(this.data.id, clientData).subscribe({
        next: () => {
          this.snackBar.open('Cliente atualizado com sucesso!', 'Fechar', { duration: 3000 });
          this.dialogRef.close(true);
        },
        error: (err) => {
          this.snackBar.open(err.error?.error || 'Erro ao atualizar cliente.', 'Fechar', { duration: 5000 });
        }
      });
    } else {
      this.clientService.create(clientData).subscribe({
        next: () => {
          this.snackBar.open('Cliente cadastrado com sucesso!', 'Fechar', { duration: 3000 });
          this.dialogRef.close(true);
        },
        error: (err) => {
          this.snackBar.open(err.error?.error || 'Erro ao cadastrar cliente.', 'Fechar', { duration: 5000 });
        }
      });
    }
  }
}
