import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:creapolis_app/core/error/failures.dart';
import 'package:creapolis_app/core/errors/exceptions.dart';
import 'package:creapolis_app/domain/entities/search_result.dart';
import 'package:creapolis_app/domain/repositories/search_repository.dart';
import 'package:creapolis_app/data/datasources/search_remote_datasource.dart';

/// Implementation of search repository
@LazySingleton(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;

  SearchRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, SearchResponse>> globalSearch(
    String query, {
    SearchFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await _remoteDataSource.globalSearch(
        query,
        filters: filters,
        page: page,
        limit: limit,
      );

      final response = SearchResponse.fromJson(result);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to perform search: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SearchResult>>> quickSearch(
    String query, {
    int limit = 5,
  }) async {
    try {
      final result = await _remoteDataSource.quickSearch(
        query,
        limit: limit,
      );

      final suggestions = result
          .map((json) => SearchResult.fromJson(json))
          .toList();

      return Right(suggestions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to perform quick search: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SearchResult>>> searchTasks(
    String query, {
    SearchFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await _remoteDataSource.searchTasks(
        query,
        filters: filters,
        page: page,
        limit: limit,
      );

      final tasks = result
          .map((json) => SearchResult.fromJson(json))
          .toList();

      return Right(tasks);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search tasks: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SearchResult>>> searchProjects(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await _remoteDataSource.searchProjects(
        query,
        page: page,
        limit: limit,
      );

      final projects = result
          .map((json) => SearchResult.fromJson(json))
          .toList();

      return Right(projects);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search projects: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SearchResult>>> searchUsers(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await _remoteDataSource.searchUsers(
        query,
        page: page,
        limit: limit,
      );

      final users = result
          .map((json) => SearchResult.fromJson(json))
          .toList();

      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search users: $e'));
    }
  }
}
