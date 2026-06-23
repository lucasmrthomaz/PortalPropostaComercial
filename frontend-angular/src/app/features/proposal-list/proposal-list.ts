import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule, CurrencyPipe, DatePipe } from '@angular/common';
import { MatTableModule, MatTableDataSource } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatSelectModule } from '@angular/material/select';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ActivatedRoute, Router } from '@angular/router';
import { MatMenuModule } from '@angular/material/menu';
import { ProposalService } from '../../core/services/proposal.service';
import { ClientService } from '../../core/services/client.service';
import { CompanyService } from '../../core/services/company.service';
import { Proposta } from '../../core/models/proposal.model';
import { Cliente } from '../../core/models/client.model';
import { PedidoAnalise } from '../../core/models/supervisor.model';
import { ProposalForm } from '../proposal-form/proposal-form';
import { ProposalDetails } from '../proposal-details/proposal-details';
import { ForwardDialog } from '../forward-dialog/forward-dialog';
import { SupervisorDialog } from '../../shared/components/supervisor-dialog/supervisor-dialog';

@Component({
  selector: 'app-proposal-list',
  imports: [
    CommonModule,
    MatTableModule,
    MatButtonModule,
    MatIconModule,
    MatCardModule,
    MatSelectModule,
    MatFormFieldModule,
    MatDialogModule,
    MatSnackBarModule,
    MatProgressSpinnerModule,
    CurrencyPipe,
    DatePipe,
    MatMenuModule
  ],
  templateUrl: './proposal-list.html',
  styleUrl: './proposal-list.scss'
})
export class ProposalList implements OnInit {
  private proposalService = inject(ProposalService);
  private clientService = inject(ClientService);
  private companyService = inject(CompanyService);
  private dialog = inject(MatDialog);
  private snackBar = inject(MatSnackBar);
  private route = inject(ActivatedRoute);

  proposals = signal<Proposta[]>([]);
  clients = signal<Cliente[]>([]);
  clientsMap = new Map<string, string>();
  dataSource = new MatTableDataSource<Proposta>([]);
  displayedColumns: string[] = ['cliente', 'tipo', 'valor', 'empresa', 'comissao', 'status', 'created_at', 'acoes'];
  loading = signal<boolean>(true);

  // Filtros
  selectedClientFilter = signal<string>('all');
  selectedTypeFilter = signal<string>('all');
  selectedStatusFilter = signal<string>('all');

  ngOnInit(): void {
    this.loadClients();
  }

  loadClients(): void {
    this.clientService.list().subscribe({
      next: (clients) => {
        this.clients.set(clients);
        clients.forEach(c => this.clientsMap.set(c.id!, c.nome));
        this.loadProposals();
      },
      error: (err) => {
        console.error('Erro ao carregar clientes', err);
        this.loadProposals();
      }
    });
  }

  loadProposals(): void {
    this.loading.set(true);
    this.proposalService.list().subscribe({
      next: (proposals) => {
        proposals.forEach(p => {
          if (typeof p.dados_especificos === 'string') {
            try {
              p.dados_especificos = JSON.parse(p.dados_especificos);
            } catch (e) {
              // Ignora erro
            }
          }
        });
        this.proposals.set(proposals);
        this.applyFilters();
        this.loading.set(false);

        // Verifica parâmetro de query
        this.route.queryParams.subscribe(params => {
          if (params['clienteId']) {
            this.selectedClientFilter.set(params['clienteId']);
            this.applyFilters();
          }
        });
      },
      error: (err) => {
        console.error('Erro ao carregar propostas', err);
        this.snackBar.open('Erro ao carregar propostas.', 'Fechar', { duration: 5000 });
        this.loading.set(false);
      }
    });
  }

  applyFilters(): void {
    let filtered = this.proposals();

    const clientFilter = this.selectedClientFilter();
    if (clientFilter !== 'all') {
      filtered = filtered.filter(p => p.cliente_id === clientFilter);
    }

    const typeFilter = this.selectedTypeFilter();
    if (typeFilter !== 'all') {
      filtered = filtered.filter(p => p.tipo === typeFilter);
    }

    const statusFilter = this.selectedStatusFilter();
    if (statusFilter !== 'all') {
      filtered = filtered.filter(p => p.status === statusFilter);
    }

    this.dataSource.data = filtered;
  }

  getClientName(clientId: string): string {
    return this.clientsMap.get(clientId) || 'Carregando...';
  }

  getTypeLabel(tipo: string): string {
    switch(tipo) {
      case 'Imobiliaria': return 'Imobiliária';
      case 'Auto': return 'Automotiva';
      case 'CompraVenda': return 'Compra/Venda Diversas';
      default: return tipo;
    }
  }

  getStatusLabel(status: string): string {
    switch(status) {
      case 'Pendente': return 'Pendente';
      case 'Aprovada': return 'Aprovada';
      case 'Recusada': return 'Recusada';
      case 'Em Analise': return 'Em Análise';
      default: return status;
    }
  }

  openProposalForm(proposal?: Proposta): void {
    let dataToSend = null;
    if (proposal) {
      dataToSend = {
        ...proposal,
        dados_especificos: { ...proposal.dados_especificos }
      };
    }
    
    const dialogRef = this.dialog.open(ProposalForm, {
      width: '700px',
      data: dataToSend
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.loadProposals();
      }
    });
  }

  deleteProposal(proposal: Proposta): void {
    const clientName = this.getClientName(proposal.cliente_id);
    const ped: PedidoAnalise = {
      tipo_acao: 'DeletarProposta',
      entidade_id: proposal.id!,
      entidade_tipo: 'Proposta',
      descricao: `Excluir proposta comercial de R$ ${proposal.valor} (Cliente: ${clientName}).`,
      dados_acao: JSON.stringify({ proposta_id: proposal.id })
    };

    const authRef = this.dialog.open(SupervisorDialog, {
      width: '550px',
      data: {
        title: 'Excluir Proposta Comercial',
        description: `Você está tentando excluir permanentemente a proposta de R$ ${proposal.valor} do cliente ${clientName}.`,
        pedido: ped
      }
    });

    authRef.afterClosed().subscribe(res => {
      if (res?.confirmed) {
        this.proposalService.delete(proposal.id!).subscribe({
          next: () => {
            this.snackBar.open('Proposta excluída com sucesso!', 'Fechar', { duration: 3000 });
            this.loadProposals();
          },
          error: (err) => {
            this.snackBar.open(err.error?.error || 'Erro ao excluir proposta.', 'Fechar', { duration: 5000 });
          }
        });
      } else if (res?.submitted) {
        this.loadProposals();
      }
    });
  }

  openDetails(proposal: Proposta): void {
    this.dialog.open(ProposalDetails, {
      width: '600px',
      data: {
        proposal,
        clientName: this.getClientName(proposal.cliente_id)
      }
    });
  }

  forwardProposal(proposal: Proposta): void {
    const dialogRef = this.dialog.open(ForwardDialog, {
      width: '450px'
    });

    dialogRef.afterClosed().subscribe((empresaId: string) => {
      if (!empresaId) return;

      this.companyService.get(empresaId).subscribe(company => {
        const clientName = this.getClientName(proposal.cliente_id);
        
        const ped: PedidoAnalise = {
          tipo_acao: 'EncaminharEmpresa',
          entidade_id: proposal.id!,
          entidade_tipo: 'Proposta',
          descricao: `Encaminhar proposta comercial de R$ ${proposal.valor} (Cliente: ${clientName}) para a empresa parceira ${company.nome}. Representante: ${company.responsavel_nome}.`,
          dados_acao: JSON.stringify({ proposta_id: proposal.id, empresa_id: empresaId })
        };

        const authRef = this.dialog.open(SupervisorDialog, {
          width: '550px',
          data: {
            title: 'Encaminhar Proposta',
            description: `Você está tentando encaminhar os dados da proposta de R$ ${proposal.valor} do cliente "${clientName}" para a empresa parceira "${company.nome}".`,
            pedido: ped
          }
        });

        authRef.afterClosed().subscribe(res => {
          if (res?.confirmed) {
            const updatedProp = {
              ...proposal,
              empresa_id: empresaId,
              status_corretagem: 'Encaminhada'
            };
            this.proposalService.update(proposal.id!, updatedProp).subscribe({
              next: () => {
                this.snackBar.open('Proposta encaminhada com sucesso!', 'Fechar', { duration: 3000 });
                this.loadProposals();
              },
              error: (err) => {
                this.snackBar.open(err.error?.error || 'Erro ao encaminhar proposta.', 'Fechar', { duration: 5000 });
              }
            });
          } else if (res?.submitted) {
            this.loadProposals();
          }
        });
      });
    });
  }

  approveProposalDirectly(proposal: Proposta): void {
    const clientName = this.getClientName(proposal.cliente_id);
    const ped: PedidoAnalise = {
      tipo_acao: 'AprovarProposta',
      entidade_id: proposal.id!,
      entidade_tipo: 'Proposta',
      descricao: `Aprovar proposta comercial de R$ ${proposal.valor} para o cliente ${clientName}.`,
      dados_acao: JSON.stringify({ proposta_id: proposal.id })
    };

    const authRef = this.dialog.open(SupervisorDialog, {
      width: '550px',
      data: {
        title: 'Aprovar Proposta Comercial',
        description: `Você está tentando aprovar a proposta de R$ ${proposal.valor} do cliente ${clientName}. Isso ativará a cobrança de corretagem caso haja empresa parceira vinculada.`,
        pedido: ped
      }
    });

    authRef.afterClosed().subscribe(res => {
      if (res?.confirmed) {
        const updatedProp = {
          ...proposal,
          status: 'Aprovada' as any
        };
        this.proposalService.update(proposal.id!, updatedProp).subscribe({
          next: () => {
            this.snackBar.open('Proposta aprovada com sucesso!', 'Fechar', { duration: 3000 });
            this.loadProposals();
          },
          error: (err) => {
            this.snackBar.open(err.error?.error || 'Erro ao aprovar proposta.', 'Fechar', { duration: 5000 });
          }
        });
      } else if (res?.submitted) {
        this.loadProposals();
      }
    });
  }
}
