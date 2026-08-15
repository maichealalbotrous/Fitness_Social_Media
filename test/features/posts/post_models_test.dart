import 'package:fitness_social_app/features/posts/data/models/post_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps post response into a domain-ready data model', () {
    final model = PostModel.fromJson({
      'id': 'post-1',
      'authorId': 'user-1',
      'communityId': null,
      'content': 'New personal record',
      'mediaUrls': ['https://example.com/post.png'],
      'likesCount': 4,
      'commentsCount': 2,
      'isLikedByCurrentUser': true,
      'createdAt': '2026-08-15T18:00:00Z',
    });

    expect(model.toEntity().id, 'post-1');
    expect(model.toEntity().content, 'New personal record');
    expect(model.toEntity().likesCount, 4);
    expect(model.toEntity().isLikedByCurrentUser, isTrue);
    expect(model.toEntity().mediaUrls, ['https://example.com/post.png']);
  });

  test('maps comment response into a domain-ready data model', () {
    final model = CommentModel.fromJson({
      'id': 'comment-1',
      'postId': 'post-1',
      'authorId': 'user-1',
      'content': 'Great work',
      'parentCommentId': null,
      'createdAt': '2026-08-15T18:01:00Z',
    });

    expect(model.toEntity().id, 'comment-1');
    expect(model.toEntity().postId, 'post-1');
    expect(model.toEntity().content, 'Great work');
  });
}
