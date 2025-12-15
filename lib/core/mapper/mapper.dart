import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/domain/entities/user.dart';
import 'mapper.auto_mappr.dart';

@AutoMappr([MapType<UserModel, User>(), MapType<User, UserModel>()])
class Mappr extends $Mappr {}
