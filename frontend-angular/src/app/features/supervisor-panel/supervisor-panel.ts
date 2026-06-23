import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { MatTableModule, MatTableDataSource } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { SupervisorService } from '../../core/services/supervisor.service';
import { PedidoAnalise } from '../../core/models/supervisor.model';

@Component({
  selector: 'app-supervisor-panel',
  imports: [
    CommonModule,
    MatTableModule,
    MatButtonModule,
    MatIconModule,
    MatCardModule,
    MatSnackBarModule,
    MatProgressSpinnerModule,
    DatePipe
  ],
  templateUrl: './supervisor-panel.html',
  styleUrl: './supervisor-panel.scss'
})
export class SupervisorPanel implements OnInit {
  private supervisorService = inject(SupervisorService);
  private snackBar = inject(MatSnackBar);

  requests = signal<PedidoAnalise[]>([]);
  dataSource = new MatTableDataSource<PedidoAnalise>([]);
  displayedColumns: string[] = ['tipo_acao', 'descricao', 'status', 'created_at', 'acoes'];
  loading = signal<boolean>(true);

  ngOnInit(): void {
    this.loadRequests();
  }

  loadRequests(): void {
    this.loading.set(true);
    this.supervisorService.list().subscribe({
      next: (data) => {
        this.requests.set(data);
        this.dataSource.data = data;
        this.loading.set(false);
      },
      error: (err) => {
        console.error('Erro ao carregar solicitações', err);
        this.snackBar.open('Erro ao carregar solicitações do supervisor.', 'Fechar', { duration: 5000 });
        this.loading.set(false);
      }
    });
  }

  approveRequest(req: PedidoAnalise): void {
    if (!req.id) return;
    this.loading.set(true);
    this.supervisorService.approve(req.id).subscribe({
      next: () => {
        this.snackBar.open('Solicitação aprovada e executada com sucesso!', 'Fechar', { duration: 3000 });
        this.loadRequests();
      },
      error: (err) => {
        this.snackBar.open(err.error?.error || 'Erro ao aprovar solicitação.', 'Fechar', { duration: 5000 });
        this.loading.set(false);
      }
    });
  }

  rejectRequest(req: PedidoAnalise): void {
    if (!req.id) return;
    if (confirm('Deseja realmente recusar esta solicitação de análise?')) {
      this.loading.set(true);
      this.supervisorService.reject(req.id).subscribe({
        next: () => {
          this.snackBar.open('Solicitação recusada com sucesso.', 'Fechar', { duration: 3000 });
          this.loadRequests();
        },
        error: (err) => {
          this.snackBar.open(err.error?.error || 'Erro ao recusar solicitação.', 'Fechar', { duration: 5000 });
          this.loading.set(false);
        }
      });
    }
  }

  getActionLabel(action: string): string {
    switch (action) {
      case 'DeletarCliente': return 'Excluir Cliente';
      case 'DeletarProposta': return 'Excluir Proposta';
      case 'AprovarProposta': return 'Aprovar Proposta';
      case 'EncaminharEmpresa': return 'Encaminhar para Empresa';
      default: return action;
    }
  }

  getStatusLabel(status?: string): string {
    switch (status) {
      case 'Pendente': return 'Pendente';
      case 'Aprovado': return 'Aprovado';
      case 'Recusado': return 'Recusado';
      default: return status || 'Pendente';
    }
  }
}
