import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatSelectModule } from '@angular/material/select';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatButtonModule } from '@angular/material/button';
import { CompanyService } from '../../core/services/company.service';
import { Empresa } from '../../core/models/company.model';

@Component({
  selector: 'app-forward-dialog',
  imports: [CommonModule, MatDialogModule, MatSelectModule, MatFormFieldModule, MatButtonModule],
  templateUrl: './forward-dialog.html',
  styleUrl: './forward-dialog.scss'
})
export class ForwardDialog implements OnInit {
  private companyService = inject(CompanyService);
  companies: Empresa[] = [];
  selectedCompanyId: string = '';

  ngOnInit(): void {
    this.companyService.list().subscribe(res => {
      // Exibe apenas empresas ativas
      this.companies = res.filter(c => c.ativo !== false);
    });
  }
}
