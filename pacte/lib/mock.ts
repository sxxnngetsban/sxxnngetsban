import type { Product, User } from '@/types';

/**
 * Données mockées en dur : aucune annonce ne transite par Supabase pour l'instant.
 * Les images pointent vers picsum.photos (photos fictives, pas de clé requise).
 */
export const MOCK_PRODUCTS: readonly Product[] = [
  {
    id: 'p1',
    title: 'Vélo de ville vintage',
    description:
      "Peugeot des années 80, révisé le mois dernier. Freins neufs, selle d'origine.",
    price: 140,
    imageUrl: 'https://picsum.photos/seed/pacte-velo/800/600',
    condition: 'bon',
    distanceKm: 0.4,
    seller: {
      id: 'u2',
      displayName: 'Camille',
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
      tier: 'or',
      karma: 2310,
    },
    createdAt: '2026-07-20T09:12:00.000Z',
  },
  {
    id: 'p2',
    title: 'Perceuse sans fil 18V',
    description: 'Deux batteries + mallette. Servi trois fois pour une étagère.',
    price: 55,
    imageUrl: 'https://picsum.photos/seed/pacte-perceuse/800/600',
    condition: 'excellent',
    distanceKm: 1.2,
    seller: {
      id: 'u3',
      displayName: 'Karim',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      tier: 'argent',
      karma: 870,
    },
    createdAt: '2026-07-21T17:45:00.000Z',
  },
  {
    id: 'p3',
    title: 'Cafetière italienne 6 tasses',
    description: 'Troc uniquement : je cherche une théière en fonte. Inox, sans traces.',
    price: 0,
    imageUrl: 'https://picsum.photos/seed/pacte-cafe/800/600',
    condition: 'neuf',
    distanceKm: 0.8,
    seller: {
      id: 'u4',
      displayName: 'Léa',
      avatarUrl: 'https://i.pravatar.cc/150?img=45',
      tier: 'bronze',
      karma: 180,
    },
    createdAt: '2026-07-22T08:03:00.000Z',
  },
  {
    id: 'p4',
    title: 'Console rétro + 2 manettes',
    description: 'Boîte d’origine, quelques rayures sur le dessus. Testée ce matin.',
    price: 90,
    imageUrl: 'https://picsum.photos/seed/pacte-console/800/600',
    condition: 'usé',
    distanceKm: 2.6,
    seller: {
      id: 'u5',
      displayName: 'Bruno',
      avatarUrl: 'https://i.pravatar.cc/150?img=59',
      tier: 'argent',
      karma: 640,
    },
    createdAt: '2026-07-22T19:30:00.000Z',
  },
  {
    id: 'p5',
    title: 'Lot de 12 pots de conserve',
    description: 'Bocaux Le Parfait 1L, joints neufs fournis. Parfait pour la rentrée.',
    price: 18,
    imageUrl: 'https://picsum.photos/seed/pacte-bocaux/800/600',
    condition: 'bon',
    distanceKm: 0.2,
    seller: {
      id: 'u6',
      displayName: 'Nadia',
      avatarUrl: 'https://i.pravatar.cc/150?img=27',
      tier: 'or',
      karma: 1980,
    },
    createdAt: '2026-07-23T11:15:00.000Z',
  },
];

/** Profil affiché tant qu'aucune session Supabase n'est disponible. */
export const MOCK_CURRENT_USER: User = {
  id: 'u1',
  email: 'toi@pacte.app',
  displayName: 'Toi',
  avatarUrl: 'https://i.pravatar.cc/150?img=68',
  karma: 1450,
  pactesCompleted: 11,
  inviteCode: 'K7X2M',
  createdAt: '2026-01-14T10:00:00.000Z',
};
