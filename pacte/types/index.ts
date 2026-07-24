/** Paliers de confiance affichés sur les profils et les cartes produit. */
export type TrustTier = 'bronze' | 'argent' | 'or';

/** État d'usure renvoyé (à terme) par le scan IA. */
export type WearCondition = 'neuf' | 'excellent' | 'bon' | 'usé';

export interface User {
  id: string;
  email: string;
  displayName: string;
  avatarUrl: string | null;
  /** Score Karma cumulé (points). */
  karma: number;
  /** Nombre de pactes menés à terme — détermine le palier de confiance. */
  pactesCompleted: number;
  /** Code court utilisé dans les liens d'invitation `pacte.app/invite/XXXXX`. */
  inviteCode: string;
  createdAt: string;
}

/** Ligne de la table `profiles` côté Supabase (snake_case). */
export interface ProfileRow {
  id: string;
  display_name: string | null;
  avatar_url: string | null;
  karma: number | null;
  pactes_completed: number | null;
  invite_code: string | null;
  created_at: string;
}

export interface Seller {
  id: string;
  displayName: string;
  avatarUrl: string;
  tier: TrustTier;
  karma: number;
}

export interface Product {
  id: string;
  title: string;
  description: string;
  /** Prix en euros. `0` = troc pur. */
  price: number;
  imageUrl: string;
  condition: WearCondition;
  distanceKm: number;
  seller: Seller;
  createdAt: string;
}

/**
 * Une transaction Pacte se valide en 2 étapes :
 * l'acheteur confirme la réception, puis le vendeur confirme le règlement.
 */
export type TransactionStatus =
  | 'proposee'
  | 'acceptee'
  | 'validee_acheteur'
  | 'validee_vendeur'
  | 'conclue'
  | 'annulee';

export interface Transaction {
  id: string;
  productId: string;
  sellerId: string;
  /** `null` tant que l'acheteur est un invité non inscrit (lien de confiance). */
  buyerId: string | null;
  guestInviteCode: string | null;
  amount: number;
  status: TransactionStatus;
  buyerValidatedAt: string | null;
  sellerValidatedAt: string | null;
  createdAt: string;
}
