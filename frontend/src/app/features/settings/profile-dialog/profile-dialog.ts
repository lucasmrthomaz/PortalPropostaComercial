import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, FormArray, FormControl, Validators } from '@angular/forms';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatDividerModule } from '@angular/material/divider';
import { MatChipsModule } from '@angular/material/chips';
import { Perfil } from '../../../core/models/user.model';

const ALL_PERMISSIONS = [
  { key: 'clients.read',     label: 'Clientes — Visualizar' },
  { key: 'clients.write',    label: 'Clientes — Criar / Editar / Excluir' },
  { key: 'proposals.read',   label: 'Propostas — Visualizar' },
  { key: 'proposals.write',  label: 'Propostas — Criar / Editar / Excluir' },
  { key: 'companies.read',   label: 'Empresas Parceiras — Visualizar' },
  { key: 'companies.write',  label: 'Empresas Parceiras — Criar / Editar / Excluir' },
  { key: 'dashboard.read',   label: 'Dashboard — Visualizar' },
  { key: 'settings.read',    label: 'Configurações — Visualizar' },
  { key: 'settings.write',   label: 'Configurações — Editar' },
  { key: 'users.read',       label: 'Usuários — Visualizar' },
  { key: 'users.write',      label: 'Usuários — Criar / Editar / Excluir' },
  { key: 'supervisor.access',label: 'Painel Supervisor' },
];

@Component({
  selector: 'app-profile-dialog',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    MatCheckboxModule,
    MatDividerModule,
    MatChipsModule,
  ],
  templateUrl: './profile-dialog.html',
  styleUrl: './profile-dialog.scss'
})
export class ProfileDialog implements OnInit {
  private fb = inject(FormBuilder);
  private dialogRef = inject(MatDialogRef<ProfileDialog>);
  protected data = inject<Perfil | null>(MAT_DIALOG_DATA);

  form!: FormGroup;
  isEditMode = false;
  isSuperAdmin = false;
  readonly allPermissions = ALL_PERMISSIONS;

  ngOnInit(): void {
    this.isEditMode = !!this.data?.id;
    this.isSuperAdmin = this.data?.nome === 'Super Admin';
    this.initForm();
  }

  initForm(): void {
    // Build a FormArray of booleans, one per permission
    let currentPerms: string[] = [];
    if (this.data?.permissoes) {
      if (typeof this.data.permissoes === 'string') {
        try { currentPerms = JSON.parse(this.data.permissoes); } catch { currentPerms = []; }
      } else {
        currentPerms = this.data.permissoes as string[];
      }
    }

    const isWildcard = currentPerms.includes('*');

    const permChecks = this.allPermissions.map(p =>
      new FormControl({ value: isWildcard || currentPerms.includes(p.key), disabled: this.isSuperAdmin })
    );

    this.form = this.fb.group({
      nome: [{ value: this.data?.nome || '', disabled: this.data?.is_sistema }, Validators.required],
      descricao: [this.data?.descricao || ''],
      permissoes: this.fb.array(permChecks),
    });
  }

  get permissoesArray(): FormArray {
    return this.form.get('permissoes') as FormArray;
  }

  get permissoesControls(): FormControl[] {
    return this.permissoesArray.controls as FormControl[];
  }

  onSubmit(): void {
    if (this.form.invalid) return;

    const raw = this.form.getRawValue();
    let permissoesSelecionadas: string[];

    if (this.isSuperAdmin) {
      permissoesSelecionadas = ['*'];
    } else {
      permissoesSelecionadas = this.allPermissions
        .filter((_, i) => raw.permissoes[i])
        .map(p => p.key);
    }

    const perfil: Perfil = {
      nome: raw.nome,
      descricao: raw.descricao,
      permissoes: permissoesSelecionadas,
      id: this.isEditMode ? this.data?.id : undefined,
    };

    this.dialogRef.close(perfil);
  }
}
