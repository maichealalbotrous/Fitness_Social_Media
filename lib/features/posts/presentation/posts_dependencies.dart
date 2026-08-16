import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:fitness_social_app/features/posts/data/repositories/post_repository_impl.dart';
import 'package:fitness_social_app/features/posts/domain/usecases/post_usecases.dart';
import 'package:fitness_social_app/features/posts/presentation/controllers/posts_controller.dart';

class PostsDependencies {
  const PostsDependencies._();

  static PostsController createController() {
    final repository = PostRepositoryImpl(
      ApiPostRemoteDataSource(
        ApiClient(sessionStorage: SecureSessionStorage()),
      ),
    );

    return PostsController(
      getFeedPosts: GetFeedPosts(repository),
      getAllPosts: GetAllPosts(repository),
      getPostById: GetPostById(repository),
      createPost: CreatePost(repository),
      deletePost: DeletePost(repository),
      togglePostLike: TogglePostLike(repository),
      getPostComments: GetPostComments(repository),
      addPostComment: AddPostComment(repository),
    );
  }
}
