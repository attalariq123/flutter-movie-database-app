import 'package:cached_network_image/cached_network_image.dart';
import 'package:ditonton/common/constants.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/common/urls.dart';
import 'package:ditonton/domain/entities/genre.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/entities/tv_detail.dart';
import 'package:ditonton/presentation/provider/tv_detail_notifier.dart';
import 'package:ditonton/presentation/widgets/horizontal_item_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TvDetailPage extends StatefulWidget {
  static const ROUTE_NAME = '/tv-detail';

  final int id;
  TvDetailPage({required this.id});

  @override
  _TvDetailPageState createState() => _TvDetailPageState();
}

class _TvDetailPageState extends State<TvDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TvDetailNotifier>(context, listen: false)
          .fetchTvDetail(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TvDetailNotifier>(
        builder: (context, provider, child) {
          if (provider.tvState == RequestState.Loading) {
            return Center(child: CircularProgressIndicator());
          } else if (provider.tvState == RequestState.Loaded) {
            final tv = provider.tv;
            return TvDetailContent(
              tv: tv,
              recommendations: provider.recommendations,
            );
          } else {
            return Text(provider.message);
          }
        },
      ),
    );
  }
}

class TvDetailContent extends StatefulWidget {
  final TvDetail tv;
  final List<Tv> recommendations;
  const TvDetailContent({required this.tv, required this.recommendations});

  @override
  State<TvDetailContent> createState() => _TvDetailContentState();
}

class _TvDetailContentState extends State<TvDetailContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: [0, 0.5, 1, 1],
            ).createShader(
              Rect.fromLTRB(0, 0, rect.width, rect.height),
            );
          },
          blendMode: BlendMode.dstIn,
          child: CachedNetworkImage(
            height: 560.0,
            width: MediaQuery.of(context).size.width,
            imageUrl: Urls.imageUrl(widget.tv.posterPath!),
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: Container(
            margin: EdgeInsets.only(top: 64.0),
            child: DraggableScrollableSheet(
              builder: (context, controller) {
                return Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: kRichBlack,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.0),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 24.0),
                        child: SingleChildScrollView(
                          controller: controller,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.tv.name,
                                style: kHeading5.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 2.0,
                                      horizontal: 8.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      widget.tv.firstAirDate.split('-')[0],
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 20.0,
                                      ),
                                      SizedBox(width: 4.0),
                                      Text(
                                        (widget.tv.voteAverage / 2)
                                            .toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 16.0),
                                  Text(
                                    '${widget.tv.numberOfSeasons} Seasons',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Text(
                                    _showEpisodeDuration(
                                        widget.tv.episodeRunTime[0]),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: () {},
                                child: Text('Add to watchlist'),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  minimumSize: Size(
                                    MediaQuery.of(context).size.width,
                                    42.0,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                widget.tv.overview,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Genres: ${_showGenres(widget.tv.genres)}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Container(
                                child: TabBar(
                                  controller: _tabController,
                                  padding: EdgeInsets.zero,
                                  indicator: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.redAccent,
                                        style: BorderStyle.solid,
                                        width: 4.0,
                                      ),
                                    ),
                                  ),
                                  tabs: [
                                    Tab(text: 'Episodes'.toUpperCase()),
                                    Tab(text: 'More like this'.toUpperCase()),
                                  ],
                                ),
                              ),
                              Container(
                                height: 170.0,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    Center(child: Text('Episodes')),
                                    Container(
                                      child: _showRecommendations(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 4.0,
                          width: 48.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              minChildSize: 0.50,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: CircleAvatar(
                backgroundColor: kRichBlack,
                foregroundColor: Colors.white,
                child: Icon(Icons.arrow_back),
              ),
            ),
          ),
        )
      ],
    );
  }

  String _showGenres(List<Genre> genres) {
    String result = '';
    genres.forEach((genre) {
      result += genre.name + ', ';
    });

    if (result.isEmpty) {
      return result;
    }

    return result.substring(0, result.length - 2);
  }

  String _showEpisodeDuration(int runtime) {
    final int hours = runtime ~/ 60;
    final int minutes = runtime % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Widget _showRecommendations() {
    return Consumer<TvDetailNotifier>(
      builder: (context, data, child) {
        if (data.recommendationsState == RequestState.Loading) {
          return Center(child: CircularProgressIndicator());
        } else if (data.recommendationsState == RequestState.Error) {
          return Text(data.message);
        } else if (data.recommendationsState == RequestState.Loaded) {
          return HorizontalItemList(
            type: ContentType.Tv,
            tvs: widget.recommendations,
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
