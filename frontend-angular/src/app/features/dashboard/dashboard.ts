import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule, CurrencyPipe } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatDividerModule } from '@angular/material/divider';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ProposalService } from '../../core/services/proposal.service';
import { DashboardStats } from '../../core/models/stats.model';

@Component({
  selector: 'app-dashboard',
  imports: [
    CommonModule,
    MatCardModule,
    MatIconModule,
    MatTableModule,
    MatDividerModule,
    MatProgressSpinnerModule,
    CurrencyPipe
  ],
  templateUrl: './dashboard.html',
  styleUrl: './dashboard.scss'
})
export class Dashboard implements OnInit {
  private proposalService = inject(ProposalService);

  stats = signal<DashboardStats | null>(null);
  loading = signal<boolean>(true);

  ngOnInit(): void {
    this.loadStats();
  }

  loadStats(): void {
    this.loading.set(true);
    this.proposalService.getStats().subscribe({
      next: (data) => {
        this.stats.set(data);
        this.loading.set(false);
      },
      error: (err) => {
        console.error('Erro ao carregar estatísticas', err);
        this.loading.set(false);
      }
    });
  }

  // Métodos auxiliares para converter chaves em arrays para listagem
  getStatusLabel(status: string): string {
    switch(status) {
      case 'Pendente': return 'Pendente';
      case 'Aprovada': return 'Aprovada';
      case 'Recusada': return 'Recusada';
      case 'Em Analise': return 'Em Análise';
      default: return status;
    }
  }

  getTypeLabel(tipo: string): string {
    switch(tipo) {
      case 'Imobiliaria': return 'Imobiliária';
      case 'Auto': return 'Automotiva';
      case 'CompraVenda': return 'Compra/Venda Diversas';
      default: return tipo;
    }
  }
}
