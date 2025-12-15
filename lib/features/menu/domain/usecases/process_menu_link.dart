import '../repositories/menu_repository.dart';

class ProcessMenuLink {
  final MenuRepository repository;

  ProcessMenuLink(this.repository);

  Future<void> call(String linkItemId) async {
    await repository.processMenuLink(linkItemId);
  }
}
