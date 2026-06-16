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
import { Router } from '@angular/router';
import { ClientService } from '../../core/services/client.service';
import { Cliente } from '../../core/models/client.model';
import { ClientForm } from '../client-form/client-form';
import { ProposalForm } from '../proposal-form/proposal-form';
import { SupervisorDialog } from '../../shared/components/supervisor-dialog/supervisor-dialog';
import { PedidoAnalise } from '../../core/models/supervisor.model';

@Component({
  selector: 'app-client-list',
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
  templateUrl: './client-list.html',
  styleUrl: './client-list.scss'
})
export class ClientList implements OnInit {
  private clientService = inject(ClientService);
  private dialog = inject(MatDialog);
  private snackBar = inject(MatSnackBar);
  private router = inject(Router);

  clients = signal<Cliente[]>([]);
  dataSource = new MatTableDataSource<Cliente>([]);
  displayedColumns: string[] = ['nome', 'cpf_cnpj', 'email', 'telefone', 'acoes'];
  loading = signal<boolean>(true);

  ngOnInit(): void {
    this.loadClients();
  }

  loadClients(): void {
    this.loading.set(true);
    this.clientService.list().subscribe({
      next: (data) => {
        this.clients.set(data);
        this.dataSource.data = data;
        this.loading.set(false);
      },
      error: (err) => {
        console.error('Erro ao carregar clientes', err);
        this.snackBar.open('Erro ao carregar clientes.', 'Fechar', { duration: 5000 });
        this.loading.set(false);
      }
    });
  }

  applyFilter(event: Event): void {
    const filterValue = (event.target as HTMLInputElement).value;
    this.dataSource.filter = filterValue.trim().toLowerCase();
  }

  openClientForm(client?: Cliente): void {
    const dialogRef = this.dialog.open(ClientForm, {
      width: '600px',
      data: client || null
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.loadClients();
      }
    });
  }

  deleteClient(client: Cliente): void {
    if (!client.id) return;

    const ped: PedidoAnalise = {
      tipo_acao: 'DeletarCliente',
      entidade_id: client.id,
      entidade_tipo: 'Cliente',
      descricao: `Excluir o cliente "${client.nome}" (CPF/CNPJ: ${client.cpf_cnpj}) e todas as suas propostas associadas.`,
      dados_acao: JSON.stringify({ cliente_id: client.id })
    };

    const dialogRef = this.dialog.open(SupervisorDialog, {
      width: '550px',
      data: {
        title: 'Excluir Cliente',
        description: `Você está tentando excluir o cliente "${client.nome}". Esta ação removerá todas as propostas associadas permanentemente.`,
        pedido: ped
      }
    });

    dialogRef.afterClosed().subscribe(res => {
      if (res?.confirmed) {
        this.clientService.delete(client.id!).subscribe({
          next: () => {
            this.snackBar.open('Cliente removido com sucesso!', 'Fechar', { duration: 3000 });
            this.loadClients();
          },
          error: (err) => {
            this.snackBar.open(err.error?.error || 'Erro ao remover cliente.', 'Fechar', { duration: 5000 });
          }
        });
      } else if (res?.submitted) {
        this.loadClients();
      }
    });
  }

  openProposalFormForClient(client: Cliente): void {
    const dialogRef = this.dialog.open(ProposalForm, {
      width: '700px',
      data: { cliente_id: client.id, cliente_nome: client.nome }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.router.navigate(['/propostas']);
      }
    });
  }

  viewClientProposals(client: Cliente): void {
    this.router.navigate(['/propostas'], { queryParams: { clienteId: client.id } });
  }
}
