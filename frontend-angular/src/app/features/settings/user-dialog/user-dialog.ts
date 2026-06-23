import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatDividerModule } from '@angular/material/divider';
import { Usuario, Perfil } from '../../../core/models/user.model';
import { PerfilService } from '../../../core/services/perfil.service';

export interface UserDialogData {
  usuario?: Usuario;
  perfis: Perfil[];
}

@Component({
  selector: 'app-user-dialog',
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
    MatSlideToggleModule,
    MatDividerModule,
  ],
  templateUrl: './user-dialog.html',
  styleUrl: './user-dialog.scss'
})
export class UserDialog implements OnInit {
  private fb = inject(FormBuilder);
  private dialogRef = inject(MatDialogRef<UserDialog>);
  protected data = inject<UserDialogData>(MAT_DIALOG_DATA);

  form!: FormGroup;
  isEditMode = false;
  showPassword = signal(false);

  ngOnInit(): void {
    this.isEditMode = !!this.data?.usuario?.id;
    this.initForm();
  }

  initForm(): void {
    const u = this.data?.usuario;
    this.form = this.fb.group({
      nome: [u?.nome || '', Validators.required],
      email: [u?.email || '', [Validators.required, Validators.email]],
      perfil_id: [u?.perfil_id || '', Validators.required],
      ativo: [u?.ativo !== undefined ? u.ativo : true],
      senha: ['', this.isEditMode ? [] : [Validators.required, Validators.minLength(6)]],
    });
  }

  togglePasswordVisibility(): void {
    this.showPassword.update(v => !v);
  }

  onSubmit(): void {
    if (this.form.invalid) return;
    const val = this.form.getRawValue();

    const result: Usuario & { senha?: string } = {
      nome: val.nome,
      email: val.email,
      perfil_id: val.perfil_id,
      ativo: val.ativo,
      id: this.isEditMode ? this.data?.usuario?.id : undefined,
    };

    if (val.senha?.trim()) {
      result.senha = val.senha;
    }

    this.dialogRef.close(result);
  }

  getPerfilName(perfilId: string): string {
    const p = this.data?.perfis?.find(p => p.id === perfilId);
    return p?.nome || perfilId;
  }
}
