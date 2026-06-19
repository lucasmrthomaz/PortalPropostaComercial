import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatTableModule } from '@angular/material/table';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatDividerModule } from '@angular/material/divider';
import { MatChipsModule } from '@angular/material/chips';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatBadgeModule } from '@angular/material/badge';
import { SettingsService } from '../../core/services/settings.service';
import { Settings } from '../../core/models/settings.model';
import { ProposalTypeService } from '../../core/services/proposal-type.service';
import { TipoProposta, CampoTipoProposta } from '../../core/models/proposal-type.model';
import { ProposalTypeDialog } from './proposal-type-dialog/proposal-type-dialog';
import { PerfilService } from '../../core/services/perfil.service';
import { UsuarioService } from '../../core/services/usuario.service';
import { Perfil, Usuario } from '../../core/models/user.model';
import { ProfileDialog } from './profile-dialog/profile-dialog';
import { UserDialog } from './user-dialog/user-dialog';
import { CompanyService } from '../../core/services/company.service';
import { Empresa } from '../../core/models/company.model';
import { CompanyForm } from '../company-form/company-form';

@Component({
  selector: 'app-settings',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    MatProgressSpinnerModule,
    MatSnackBarModule,
    MatTableModule,
    MatDialogModule,
    MatDividerModule,
    MatChipsModule,
    MatTooltipModule,
    MatBadgeModule,
  ],
  templateUrl: './settings.html',
  styleUrl: './settings.scss'
})
export class SettingsComponent implements OnInit {
  private fb = inject(FormBuilder);
  private settingsService = inject(SettingsService);
  private proposalTypeService = inject(ProposalTypeService);
  private perfilService = inject(PerfilService);
  private usuarioService = inject(UsuarioService);
  private companyService = inject(CompanyService);
  private snackBar = inject(MatSnackBar);
  private dialog = inject(MatDialog);

  settingsForm!: FormGroup;
  loading = signal<boolean>(true);

  proposalTypes = signal<TipoProposta[]>([]);
  displayedColumnsTypes: string[] = ['nome', 'chave', 'campos', 'acoes'];

  perfis = signal<Perfil[]>([]);
  displayedColumnsPerfis: string[] = ['nome', 'descricao', 'permissoes', 'acoes'];

  usuarios = signal<Usuario[]>([]);
  displayedColumnsUsuarios: string[] = ['nome', 'email', 'perfil', 'status', 'acoes'];

  companies = signal<Empresa[]>([]);
  displayedColumnsCompanies: string[] = ['nome', 'cnpj', 'email', 'responsavel', 'status', 'acoes'];

  ngOnInit(): void {
    this.initForm();
    this.loadSettings();
    this.loadAll();
  }

  initForm(): void {
    this.settingsForm = this.fb.group({
      taxa_corretagem: [5.0, [Validators.required, Validators.min(0), Validators.max(100)]],
      senha_supervisor: ['', [Validators.minLength(4)]]
    });
  }

  loadAll(): void {
    this.loadProposalTypes();
    this.loadPerfis();
    this.loadUsuarios();
    this.loadCompanies();
  }

  loadSettings(): void {
    this.settingsService.get().subscribe({
      next: (data) => {
        this.settingsForm.patchValue({ taxa_corretagem: data.taxa_corretagem });
        this.loading.set(false);
      },
      error: () => {
        this.snackBar.open('Erro ao carregar configurações.', 'Fechar', { duration: 5000 });
        this.loading.set(false);
      }
    });
  }

  loadProposalTypes(): void {
    this.proposalTypeService.list().subscribe({
      next: (data) => this.proposalTypes.set(data),
      error: () => this.snackBar.open('Erro ao carregar tipos de proposta.', 'Fechar', { duration: 5000 })
    });
  }

  loadPerfis(): void {
    this.perfilService.list().subscribe({
      next: (data) => this.perfis.set(data),
      error: () => this.snackBar.open('Erro ao carregar perfis de acesso.', 'Fechar', { duration: 5000 })
    });
  }

  loadUsuarios(): void {
    this.usuarioService.list().subscribe({
      next: (data) => this.usuarios.set(data),
      error: () => this.snackBar.open('Erro ao carregar usuários.', 'Fechar', { duration: 5000 })
    });
  }

  loadCompanies(): void {
    this.companyService.list().subscribe({
      next: (data) => this.companies.set(data),
      error: () => this.snackBar.open('Erro ao carregar empresas parceiras.', 'Fechar', { duration: 5000 })
    });
  }

  // ===============================
  // PROPOSAL TYPE CRUD
  // ===============================
  openProposalTypeDialog(tipo?: TipoProposta): void {
    const dialogRef = this.dialog.open(ProposalTypeDialog, {
      width: '800px',
      maxWidth: '95vw',
      data: tipo ? { ...tipo } : null
    });

    dialogRef.afterClosed().subscribe((result: TipoProposta | undefined) => {
      if (!result) return;
      if (result.id) {
        this.proposalTypeService.update(result.id, result).subscribe({
          next: () => { this.snackBar.open('Tipo atualizado!', 'Fechar', { duration: 3000 }); this.loadProposalTypes(); },
          error: (err) => this.snackBar.open(err.error?.error || 'Erro ao atualizar.', 'Fechar', { duration: 5000 })
        });
      } else {
        this.proposalTypeService.create(result).subscribe({
          next: () => { this.snackBar.open('Tipo criado!', 'Fechar', { duration: 3000 }); this.loadProposalTypes(); },
          error: (err) => this.snackBar.open(err.error?.error || 'Erro ao criar.', 'Fechar', { duration: 5000 })
        });
      }
    });
  }

  deleteProposalType(tipo: TipoProposta): void {
    if (tipo.chave === 'Imobiliaria' || tipo.chave === 'Auto' || tipo.chave === 'CompraVenda') return;
    if (confirm(`Excluir o tipo "${tipo.nome}"?`)) {
      this.proposalTypeService.delete(tipo.id!).subscribe({
        next: () => { this.snackBar.open('Tipo excluído!', 'Fechar', { duration: 3000 }); this.loadProposalTypes(); },
        error: (err) => this.snackBar.open(err.error?.error || 'Erro ao excluir.', 'Fechar', { duration: 5000 })
      });
    }
  }

  getFieldNamesList(tipo: TipoProposta): string {
    if (!tipo.campos) return 'Nenhum campo';
    let fieldsList: CampoTipoProposta[] = [];
    if (typeof tipo.campos === 'string') {
      try { fieldsList = JSON.parse(tipo.campos); } catch { return 'Erro ao ler campos'; }
    } else {
      fieldsList = tipo.campos;
    }
    if (fieldsList.length === 0) return 'Nenhum campo';
    return fieldsList.map(c => `${c.nome}${c.obrigatorio ? '*' : ''}`).join(', ');
  }

  // ===============================
  // PROFILE CRUD
  // ===============================
  openProfileDialog(perfil?: Perfil): void {
    const dialogRef = this.dialog.open(ProfileDialog, {
      width: '680px',
      maxWidth: '95vw',
      data: perfil ? { ...perfil } : null
    });

    dialogRef.afterClosed().subscribe((result: Perfil | undefined) => {
      if (!result) return;
      if (result.id) {
        this.perfilService.update(result.id, result).subscribe({
          next: () => { this.snackBar.open('Perfil atualizado!', 'Fechar', { duration: 3000 }); this.loadPerfis(); },
          error: (err) => this.snackBar.open(err.error?.error || 'Erro ao atualizar perfil.', 'Fechar', { duration: 5000 })
        });
      } else {
        this.perfilService.create(result).subscribe({
          next: () => { this.snackBar.open('Perfil criado!', 'Fechar', { duration: 3000 }); this.loadPerfis(); },
          error: (err) => this.snackBar.open(err.error?.error || 'Erro ao criar perfil.', 'Fechar', { duration: 5000 })
        });
      }
    });
  }

  deletePerfil(perfil: Perfil): void {
    if (perfil.is_sistema) {
      this.snackBar.open('Perfis do sistema não podem ser excluídos.', 'Fechar', { duration: 4000 });
      return;
    }
    if (confirm(`Excluir o perfil "${perfil.nome}"?`)) {
      this.perfilService.delete(perfil.id!).subscribe({
        next: () => { this.snackBar.open('Perfil excluído!', 'Fechar', { duration: 3000 }); this.loadPerfis(); },
        error: (err) => this.snackBar.open(err.error?.error || 'Erro ao excluir perfil.', 'Fechar', { duration: 5000 })
      });
    }
  }

  getPermissoesList(perfil: Perfil): string {
    let perms: string[] = [];
    if (typeof perfil.permissoes === 'string') {
      try { perms = JSON.parse(perfil.permissoes); } catch { return '—'; }
    } else if (Array.isArray(perfil.permissoes)) {
      perms = perfil.permissoes;
    }
    if (perms.includes('*')) return 'Acesso Total (★)';
    if (perms.length === 0) return 'Nenhuma permissão';
    return `${perms.length} permissão(ões)`;
  }

  // ===============================
  // USER CRUD
  // ===============================
  openUserDialog(usuario?: Usuario): void {
    const dialogRef = this.dialog.open(UserDialog, {
      width: '520px',
      maxWidth: '95vw',
      data: { usuario: usuario ? { ...usuario } : undefined, perfis: this.perfis() }
    });

    dialogRef.afterClosed().subscribe((result: (Usuario & { senha?: string }) | undefined) => {
      if (!result) return;
      const { senha, ...usuarioData } = result;
      const payload = { ...usuarioData, ...(senha ? { senha } : {}) };

      if (result.id) {
        this.usuarioService.update(result.id, payload).subscribe({
          next: () => { this.snackBar.open('Usuário atualizado!', 'Fechar', { duration: 3000 }); this.loadUsuarios(); },
          error: (err) => this.snackBar.open(err.error?.error || 'Erro ao atualizar usuário.', 'Fechar', { duration: 5000 })
        });
      } else {
        this.usuarioService.create(payload as Usuario & { senha: string }).subscribe({
          next: () => { this.snackBar.open('Usuário criado!', 'Fechar', { duration: 3000 }); this.loadUsuarios(); },
          error: (err) => this.snackBar.open(err.error?.error || 'Erro ao criar usuário.', 'Fechar', { duration: 5000 })
        });
      }
    });
  }

  deleteUsuario(usuario: Usuario): void {
    if (confirm(`Excluir o usuário "${usuario.nome}"?`)) {
      this.usuarioService.delete(usuario.id!).subscribe({
        next: () => { this.snackBar.open('Usuário excluído!', 'Fechar', { duration: 3000 }); this.loadUsuarios(); },
        error: (err) => this.snackBar.open(err.error?.error || 'Erro ao excluir usuário.', 'Fechar', { duration: 5000 })
      });
    }
  }

  // ===============================
  // COMPANY CRUD
  // ===============================
  openCompanyDialog(company?: Empresa): void {
    const dialogRef = this.dialog.open(CompanyForm, {
      width: '650px',
      maxWidth: '95vw',
      data: company || null
    });

    dialogRef.afterClosed().subscribe((result: boolean | undefined) => {
      if (result) {
        this.loadCompanies();
      }
    });
  }

  deleteCompany(company: Empresa): void {
    if (confirm(`Deseja realmente excluir a empresa parceira "${company.nome}"?`)) {
      if (!company.id) return;
      this.companyService.delete(company.id).subscribe({
        next: () => {
          this.snackBar.open('Empresa parceira excluída com sucesso!', 'Fechar', { duration: 3000 });
          this.loadCompanies();
        },
        error: (err) => {
          this.snackBar.open(err.error?.error || 'Erro ao excluir empresa.', 'Fechar', { duration: 5000 });
        }
      });
    }
  }

  // ===============================
  // GENERAL SETTINGS
  // ===============================
  onSubmit(): void {
    if (this.settingsForm.invalid) return;
    this.loading.set(true);
    const formVal = this.settingsForm.value;
    const updateData: Settings = { taxa_corretagem: Number(formVal.taxa_corretagem) };
    if (formVal.senha_supervisor?.trim()) {
      updateData.senha_supervisor = formVal.senha_supervisor;
    }
    this.settingsService.update(updateData).subscribe({
      next: () => {
        this.snackBar.open('Configurações salvas!', 'Fechar', { duration: 3000 });
        this.settingsForm.get('senha_supervisor')?.reset();
        this.loading.set(false);
      },
      error: () => {
        this.snackBar.open('Erro ao salvar configurações.', 'Fechar', { duration: 5000 });
        this.loading.set(false);
      }
    });
  }
}
