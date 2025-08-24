import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/loans/presentation/pages/loans_list_page.dart';
import '../../features/loans/presentation/pages/loan_form_page.dart';
import '../../features/loans/presentation/pages/loan_detail_page.dart';
import '../../features/loans/presentation/pages/early_form_page.dart';
import '../../features/loans/presentation/pages/insurance_editor_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'loans-list',
        builder: (context, state) => const LoansListPage(),
      ),
      GoRoute(
        path: '/loan/create',
        name: 'loan-create',
        builder: (context, state) => const LoanFormPage(),
      ),
      GoRoute(
        path: '/loan/:id/edit',
        name: 'loan-edit',
        builder: (context, state) {
          final loanId = state.pathParameters['id']!;
          return LoanFormPage(loanId: loanId);
        },
      ),
      GoRoute(
        path: '/loan/:id',
        name: 'loan-detail',
        builder: (context, state) {
          final loanId = state.pathParameters['id']!;
          return LoanDetailPage(loanId: loanId);
        },
      ),
      GoRoute(
        path: '/loan/:id/early/create',
        name: 'early-create',
        builder: (context, state) {
          final loanId = state.pathParameters['id']!;
          return EarlyFormPage(loanId: loanId);
        },
      ),
      GoRoute(
        path: '/loan/:id/early/:earlyId/edit',
        name: 'early-edit',
        builder: (context, state) {
          final loanId = state.pathParameters['id']!;
          final earlyId = state.pathParameters['earlyId']!;
          return EarlyFormPage(loanId: loanId, earlyRepaymentId: earlyId);
        },
      ),
      GoRoute(
        path: '/loan/:id/insurance',
        name: 'insurance-editor',
        builder: (context, state) {
          final loanId = state.pathParameters['id']!;
          return InsuranceEditorPage(loanId: loanId);
        },
      ),
    ],
  );
});
