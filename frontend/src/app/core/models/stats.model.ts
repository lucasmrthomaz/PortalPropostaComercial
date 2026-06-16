export interface DashboardStats {
  total_clients: number;
  total_proposals: number;
  total_companies: number;
  total_value: number;
  closed_commissions_value: number;
  pending_commissions_value: number;
  proposals_by_status: { [key: string]: number };
  proposals_by_type: { [key: string]: number };
  value_by_status: { [key: string]: number };
  value_by_type: { [key: string]: number };
}
