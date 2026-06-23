import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatIconModule } from '@angular/material/icon';
import { SupervisorService } from '../../../core/services/supervisor.service';
import { PedidoAnalise } from '../../../core/models/supervisor.model';

@Component({
  selector: 'app-supervisor-dialog',
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatSnackBarModule,
    MatIconModule
  ],
  templateUrl: './supervisor-dialog.html',
  styleUrl: './supervisor-dialog.scss'
})
export class SupervisorDialog {
  private fb = inject(FormBuilder);
  private supervisorService = inject(SupervisorService);
  private snackBar = inject(MatSnackBar);
  private dialogRef = inject(MatDialogRef<SupervisorDialog>);
  protected data = inject<{ title: string; description: string; pedido: PedidoAnalise }>(MAT_DIALOG_DATA);

  passwordForm: FormGroup = this.fb.group({
    password: ['', [Validators.required]]
  });

  loading = signal<boolean>(false);

  verifyAndPasswordApprove(): void {
    if (this.passwordForm.invalid) return;

    this.loading.set(true);
    const pwd = this.passwordForm.value.password;

    this.supervisorService.verifyPassword(pwd).subscribe({
      next: (res) => {
        if (res.valid) {
          this.snackBar.open('Senha confirmada! Ação realizada.', 'Fechar', { duration: 3000 });
          this.dialogRef.close({ confirmed: true, passwordUsed: true, password: pwd });
        } else {
          this.snackBar.open('Senha do supervisor inválida!', 'Fechar', { duration: 4000 });
          this.loading.set(false);
        }
      },
      error: (err) => {
        this.snackBar.open('Erro ao verificar senha do supervisor.', 'Fechar', { duration: 4000 });
        this.loading.set(false);
      }
    });
  }

  submitForAnalysis(): void {
    this.loading.set(true);
    const requestData: PedidoAnalise = this.data.pedido;

    this.supervisorService.createRequest(requestData).subscribe({
      next: () => {
        this.snackBar.open('Solicitação enviada para a análise do Supervisor!', 'Fechar', { duration: 5000 });
        this.dialogRef.close({ submitted: true });
      },
      error: (err) => {
        this.snackBar.open('Erro ao criar solicitação de análise.', 'Fechar', { duration: 4000 });
        this.loading.set(false);
      }
    });
  }
}
