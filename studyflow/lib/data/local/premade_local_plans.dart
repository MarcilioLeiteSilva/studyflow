import '../models/task_model.dart';

class LocalPlanItem {
  final String title;
  final String category;
  final int priority;
  final int dayOffset;

  const LocalPlanItem({
    required this.title,
    required this.category,
    required this.priority,
    required this.dayOffset,
  });
}

class PremadeLocalPlan {
  final String id;
  final String title;
  final String category;
  final String description;
  final int durationDays;
  final List<LocalPlanItem> items;

  const PremadeLocalPlan({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.durationDays,
    required this.items,
  });

  List<TaskModel> toTaskModels({DateTime? startDate}) {
    final base = startDate ?? DateTime.now();
    return items.map((item) {
      final deadline = base.add(Duration(days: item.dayOffset));
      return TaskModel.create(
        title: item.title,
        category: item.category,
        priority: item.priority,
        deadline: deadline,
      );
    }).toList();
  }
}

class PremadeLocalPlans {
  static const List<PremadeLocalPlan> embeddedPlans = [
    PremadeLocalPlan(
      id: 'local-matematica',
      title: 'Matemática Essencial',
      category: 'Exatas',
      description: 'Plano completo de 10 dias com álgebra, geometria, funções, trigonometria e exercícios práticos.',
      durationDays: 10,
      items: [
        LocalPlanItem(title: 'Álgebra: Equações, Sistemas e Fatoração', category: 'Matemática', priority: 2, dayOffset: 0),
        LocalPlanItem(title: 'Geometria Plana: Áreas, Perímetros e Pitágoras', category: 'Matemática', priority: 2, dayOffset: 1),
        LocalPlanItem(title: 'Funções: Função Afim e Função Quadrática', category: 'Matemática', priority: 2, dayOffset: 2),
        LocalPlanItem(title: 'Trigonometria no Triângulo Retângulo e Círculo', category: 'Matemática', priority: 1, dayOffset: 3),
        LocalPlanItem(title: 'Estatística: Média, Mediana, Moda e Gráficos', category: 'Matemática', priority: 1, dayOffset: 4),
        LocalPlanItem(title: 'Probabilidade e Análise Combinatória Básica', category: 'Matemática', priority: 2, dayOffset: 5),
        LocalPlanItem(title: 'Geometria Espacial: Prismas, Cilindros e Cones', category: 'Matemática', priority: 1, dayOffset: 6),
        LocalPlanItem(title: 'Matemática Financeira: Porcentagem e Juros', category: 'Matemática', priority: 1, dayOffset: 7),
        LocalPlanItem(title: 'Resolução de 30 Questões Práticas', category: 'Matemática', priority: 2, dayOffset: 8),
        LocalPlanItem(title: 'Simulado de Revisão Geral de Matemática', category: 'Matemática', priority: 2, dayOffset: 9),
      ],
    ),
    PremadeLocalPlan(
      id: 'local-portugues',
      title: 'Português Completo',
      category: 'Linguagens',
      description: 'Plano completo de 10 dias com gramática, concordância, regência, crase, pontuação e interpretação.',
      durationDays: 10,
      items: [
        LocalPlanItem(title: 'Interpretação e Tipologia Textual (Narrativo, Dissertativo)', category: 'Português', priority: 2, dayOffset: 0),
        LocalPlanItem(title: 'Classes Gramaticais: Substantivos, Adjetivos e Verbos', category: 'Português', priority: 1, dayOffset: 1),
        LocalPlanItem(title: 'Sintaxe: Termos Essenciais (Sujeito e Predicado)', category: 'Português', priority: 2, dayOffset: 2),
        LocalPlanItem(title: 'Concordância Verbal: Casos Gerais e Casos Especiais', category: 'Português', priority: 2, dayOffset: 3),
        LocalPlanItem(title: 'Concordância Nominal e Regras com Adjetivos', category: 'Português', priority: 1, dayOffset: 4),
        LocalPlanItem(title: 'Regência Verbal, Nominal e Emprego da Crase', category: 'Português', priority: 2, dayOffset: 5),
        LocalPlanItem(title: 'Pontuação: Emprego da Vírgula e Ponto e Vírgula', category: 'Português', priority: 2, dayOffset: 6),
        LocalPlanItem(title: 'Semântica: Sinônimos, Antônimos e Figuras de Linguagem', category: 'Português', priority: 1, dayOffset: 7),
        LocalPlanItem(title: 'Coesão e Coerência Textual com Produção de Texto', category: 'Português', priority: 2, dayOffset: 8),
        LocalPlanItem(title: 'Simulado de Revisão com 40 Questões Comentadas', category: 'Português', priority: 2, dayOffset: 9),
      ],
    ),
    PremadeLocalPlan(
      id: 'local-geografia',
      title: 'Geografia Geral e do Brasil',
      category: 'Humanas',
      description: 'Plano completo de 10 dias com geografia física, clima, relevo, demografia, urbanização e geopolítica.',
      durationDays: 10,
      items: [
        LocalPlanItem(title: 'Cartografia: Escalas, Fusos Horários e Projeções', category: 'Geografia', priority: 1, dayOffset: 0),
        LocalPlanItem(title: 'Geografia Física: Relevo, Tectonismo e Solos', category: 'Geografia', priority: 2, dayOffset: 1),
        LocalPlanItem(title: 'Climatologia: Fatores Climáticos e Massas de Ar', category: 'Geografia', priority: 2, dayOffset: 2),
        LocalPlanItem(title: 'Hidrografia: Bacias Hidrográficas Brasileiras', category: 'Geografia', priority: 1, dayOffset: 3),
        LocalPlanItem(title: 'Biomas Brasileiros: Amazônia, Cerrado, Mata Atlântica e Caatinga', category: 'Geografia', priority: 2, dayOffset: 4),
        LocalPlanItem(title: 'Urbanização e Metropolização no Brasil', category: 'Geografia', priority: 1, dayOffset: 5),
        LocalPlanItem(title: 'Demografia: Pirâmides Etárias e Migrações', category: 'Geografia', priority: 1, dayOffset: 6),
        LocalPlanItem(title: 'Agropecuária Brasileira e Estrutura Fundiária', category: 'Geografia', priority: 2, dayOffset: 7),
        LocalPlanItem(title: 'Globalização, Blocos Econômicos e Geopolítica Atual', category: 'Geografia', priority: 2, dayOffset: 8),
        LocalPlanItem(title: 'Impactos Ambientais, Sustentabilidade e Revisão', category: 'Geografia', priority: 2, dayOffset: 9),
      ],
    ),
  ];
}

