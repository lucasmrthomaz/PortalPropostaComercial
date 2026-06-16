import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule, MatTableDataSource } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { CompanyService } from '../../core/services/company.service';
import { Empresa } from '../../core/models/company.model';
import { CompanyForm } from '../company-form/company-form';

@Component({
  selector: 'app-company-list',
  imports: [
    CommonModule,
    MatTableModule,
    MatButtonModule,
    MatIconModule,
    MatCardModule,
    MatInputModule,
    MatFormFieldModule,
    MatDialogModule,
    MatSnackBarModule,
    MatProgressSpinnerModule
  ],
  templateUrl: './company-list.html',
  styleUrl: './company-list.scss'
})
export class CompanyList implements OnInit {
  private companyService = inject(CompanyService);
  private dialog = inject(MatDialog);
  private snackBar = inject(MatSnackBar);

  companies = signal<Empresa[]>([]);
  dataSource = new MatTableDataSource<Empresa>([]);
  displayedColumns: string[] = ['nome', 'cnpj', 'email', 'responsavel', 'status', 'acoes'];
  loading = signal<boolean>(true);

  ngOnInit(): void {
    this.loadCompanies();
  }

  loadCompanies(): void {
    this.loading.set(true);
    this.companyService.list().subscribe({
      next: (data) => {
        this.companies.set(data);
        this.dataSource.data = data;
        this.loading.set(false);
      },
      error: (err) => {
        console.error('Erro ao carregar empresas parceiras', err);
        this.snackBar.open('Erro ao carregar empresas parceiras.', 'Fechar', { duration: 5000 });
        this.loading.set(false);
      }
    });
  }

  applyFilter(event: Event): void {
    const filterValue = (event.target as HTMLInputElement).value;
    this.dataSource.filter = filterValue.trim().toLowerCase();
  }

  openCompanyForm(company?: Empresa): void {
    const dialogRef = this.dialog.open(CompanyForm, {
      width: '650px',
      data: company || null
    });

    dialogRef.afterClosed().subscribe(result => {
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
}
