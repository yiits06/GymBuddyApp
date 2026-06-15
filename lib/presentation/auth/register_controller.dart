import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterState {
  final int currentStep;
  final String fullName;
  final String email;
  final String password;
  final DateTime? birthDate;
  final List<String> selectedGoals;
  final String? selectedExperience;
  final String? selectedGym;

  RegisterState({
    this.currentStep = 1,
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.birthDate,
    this.selectedGoals = const [],
    this.selectedExperience,
    this.selectedGym,
  });

  RegisterState copyWith({
    int? currentStep,
    String? fullName,
    String? email,
    String? password,
    DateTime? birthDate,
    List<String>? selectedGoals,
    String? selectedExperience,
    String? selectedGym,
  }) {
    return RegisterState(
      currentStep: currentStep ?? this.currentStep,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      birthDate: birthDate ?? this.birthDate,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      selectedExperience: selectedExperience ?? this.selectedExperience,
      selectedGym: selectedGym ?? this.selectedGym,
    );
  }
}

// Sağlam ve çalışan yapıya geri döndük
class RegisterNotifier extends Notifier<RegisterState> {
  @override
  RegisterState build() {
    return RegisterState();
  }

  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updateAccountInfo(String name, String email, String pass) {
    state = state.copyWith(fullName: name, email: email, password: pass);
  }

  void setBirthDate(DateTime birthDate) {
    state = state.copyWith(birthDate: birthDate);
  }

  void toggleGoal(String goal) {
    final goals = List<String>.from(state.selectedGoals);
    if (goals.contains(goal)) {
      goals.remove(goal);
    } else {
      goals.add(goal);
    }
    state = state.copyWith(selectedGoals: goals);
  }

  void setExperience(String experience) {
    state = state.copyWith(selectedExperience: experience);
  }

  void setGym(String gym) {
    state = state.copyWith(selectedGym: gym);
  }

  // İŞTE ÇÖZÜM: Ekrandan çıkıldığında her şeyi sıfırlayacak manuel fonksiyon
  void reset() {
    state = RegisterState();
  }
}

final registerProvider = NotifierProvider<RegisterNotifier, RegisterState>(() {
  return RegisterNotifier();
});
