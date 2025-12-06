import 'package:srumec_app/users/data/datasources/users_remote_data_source.dart';
import 'package:srumec_app/users/models/user_profile.dart';

class UsersRepository {
  final UsersRemoteDataSource dataSource;
  UsersRepository(this.dataSource);

  Future<UserProfile> getUser(String id) => dataSource.getUserProfile(id);
}
