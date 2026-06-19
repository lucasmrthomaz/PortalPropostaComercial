import { Component, OnInit, inject } from '@angular/core';
import { CommonModule, CurrencyPipe, DatePipe } from '@angular/common';
import { MatDialogModule, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDividerModule } from '@angular/material/divider';
import { Proposta } from '../../core/models/proposal.model';
import { ProposalTypeService } from '../../core/services/proposal-type.service';
import { TipoProposta, CampoTipoProposta } from '../../core/models/proposal-type.model';

@Component({
  selector: 'app-proposal-details',
  imports: [
    CommonModule,
    MatDialogModule,
    MatButtonModule,
    MatIconModule,
    MatDividerModule,
    CurrencyPipe,
    DatePipe
  ],
  templateUrl: './proposal-details.html',
  styleUrl: './proposal-details.scss'
})
export class ProposalDetails implements OnInit {
  protected data = inject<{ proposal: Proposta; clientName: string }>(MAT_DIALOG_DATA);
  private proposalTypeService = inject(ProposalTypeService);
  proposalTypes: TipoProposta[] = [];

  ngOnInit(): void {
    this.loadProposalTypes();
    if (this.data.proposal && typeof this.data.proposal.dados_especificos === 'string') {
      try {
        this.data.proposal.dados_especificos = JSON.parse(this.data.proposal.dados_especificos);
      } catch (e) {
        console.error('Erro ao fazer parse de dados especificos nos detalhes', e);
      }
    }
  }

  loadProposalTypes(): void {
    this.proposalTypeService.list().subscribe({
      next: (types) => {
        this.proposalTypes = types;
      },
      error: (err) => {
        console.error('Erro ao carregar tipos de proposta', err);
      }
    });
  }

  getTypeLabel(tipo: string): string {
    const found = this.proposalTypes.find(t => t.chave === tipo);
    return found ? found.nome : tipo;
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

  getCustomFields(): { label: string; value: any }[] {
    const proposal = this.data.proposal;
    if (!proposal.dados_especificos) return [];

    let specData: any = {};
    if (typeof proposal.dados_especificos === 'string') {
      try {
        specData = JSON.parse(proposal.dados_especificos);
      } catch (e) {
        return [];
      }
    } else {
      specData = proposal.dados_especificos;
    }

    const foundType = this.proposalTypes.find(t => t.chave === proposal.tipo);
    if (!foundType || !foundType.campos) {
      // Fallback
      return Object.keys(specData).map(key => {
        const label = key
          .replace(/_/g, ' ')
          .replace(/\b\w/g, c => c.toUpperCase());
        return { label, value: this.formatValue(specData[key]) };
      });
    }

    let fieldsList: CampoTipoProposta[] = [];
    if (typeof foundType.campos === 'string') {
      try {
        fieldsList = JSON.parse(foundType.campos);
      } catch (e) {
        // Fallback
      }
    } else {
      fieldsList = foundType.campos;
    }

    return fieldsList.map(c => {
      const rawVal = specData[c.chave];
      return {
        label: c.nome,
        value: this.formatValue(rawVal, c.tipo)
      };
    });
  }

  formatValue(val: any, tipo?: string): string {
    if (val === undefined || val === null) return '-';
    if (tipo === 'boolean' || typeof val === 'boolean') {
      return val ? 'Sim' : 'Não';
    }
    return String(val);
  }
}
