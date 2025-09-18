import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';

import '../../shared/providers/reown_provider.dart';
import '../../shared/widgets/tokon_logo.dart';

/// Database NFT Service
class DatabaseNFTService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get NFTs claimed by a specific wallet address
  Future<List<DatabaseNFT>> getClaimedNFTs(String walletAddress) async {
    try {
      final response = await _supabase
          .from('boundaries')
          .select('''
            id,
            event_id,
            name,
            description,
            image_url,
            latitude,
            longitude,
            radius,
            nft_token_id,
            nft_contract_address,
            nft_metadata_ipfs_hash,
            nft_image_ipfs_hash,
            nft_metadata,
            is_claimed,
            claimed_by,
            claimed_at,
            claim_tx_hash,
            event_name,
            event_code,
            created_at
          ''')
          .eq('claimed_by', walletAddress.toLowerCase())
          .eq('is_claimed', true)
          .order('claimed_at', ascending: false);

      return (response as List)
          .map((json) => DatabaseNFT.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch claimed NFTs: $e');
    }
  }

  /// Get all claimed NFTs (for community view)
  Future<List<DatabaseNFT>> getAllClaimedNFTs() async {
    try {
      final response = await _supabase
          .from('boundaries')
          .select('''
            id,
            event_id,
            name,
            description,
            image_url,
            latitude,
            longitude,
            radius,
            nft_token_id,
            nft_contract_address,
            nft_metadata_ipfs_hash,
            nft_image_ipfs_hash,
            nft_metadata,
            is_claimed,
            claimed_by,
            claimed_at,
            claim_tx_hash,
            event_name,
            event_code,
            created_at
          ''')
          .eq('is_claimed', true)
          .order('claimed_at', ascending: false);

      return (response as List)
          .map((json) => DatabaseNFT.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all claimed NFTs: $e');
    }
  }

  /// Get NFTs by event ID
  Future<List<DatabaseNFT>> getNFTsByEvent(String eventId) async {
    try {
      final response = await _supabase
          .from('boundaries')
          .select('''
            id,
            event_id,
            name,
            description,
            image_url,
            latitude,
            longitude,
            radius,
            nft_token_id,
            nft_contract_address,
            nft_metadata_ipfs_hash,
            nft_image_ipfs_hash,
            nft_metadata,
            is_claimed,
            claimed_by,
            claimed_at,
            claim_tx_hash,
            event_name,
            event_code,
            created_at
          ''')
          .eq('event_id', eventId)
          .eq('is_claimed', true)
          .order('claimed_at', ascending: false);

      return (response as List)
          .map((json) => DatabaseNFT.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch NFTs for event: $e');
    }
  }
}

/// Database NFT Model
class DatabaseNFT {
  final String id;
  final String eventId;
  final String name;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final double radius;
  final String? nftTokenId;
  final String? nftContractAddress;
  final String? nftMetadataIpfsHash;
  final String? nftImageIpfsHash;
  final Map<String, dynamic>? nftMetadata;
  final bool isClaimed;
  final String? claimedBy;
  final DateTime? claimedAt;
  final String? claimTxHash;
  final String? eventName;
  final String? eventCode;
  final DateTime createdAt;

  DatabaseNFT({
    required this.id,
    required this.eventId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.nftTokenId,
    this.nftContractAddress,
    this.nftMetadataIpfsHash,
    this.nftImageIpfsHash,
    this.nftMetadata,
    required this.isClaimed,
    this.claimedBy,
    this.claimedAt,
    this.claimTxHash,
    this.eventName,
    this.eventCode,
    required this.createdAt,
  });

  factory DatabaseNFT.fromJson(Map<String, dynamic> json) {
    return DatabaseNFT(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num?)?.toDouble() ?? 2.0,
      nftTokenId: json['nft_token_id'] as String?,
      nftContractAddress: json['nft_contract_address'] as String?,
      nftMetadataIpfsHash: json['nft_metadata_ipfs_hash'] as String?,
      nftImageIpfsHash: json['nft_image_ipfs_hash'] as String?,
      nftMetadata: json['nft_metadata'] as Map<String, dynamic>?,
      isClaimed: json['is_claimed'] as bool? ?? false,
      claimedBy: json['claimed_by'] as String?,
      claimedAt: json['claimed_at'] != null 
          ? DateTime.parse(json['claimed_at'] as String)
          : null,
      claimTxHash: json['claim_tx_hash'] as String?,
      eventName: json['event_name'] as String?,
      eventCode: json['event_code'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get displayName => name;
  String get displayDescription => description;
  String get formattedImageUrl => imageUrl;
  bool get hasValidImage => imageUrl.isNotEmpty;
  String get locationString => '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  String get radiusString => '${radius}m';
  String get shortWalletAddress => claimedBy != null 
      ? '${claimedBy!.substring(0, 6)}...${claimedBy!.substring(claimedBy!.length - 4)}'
      : 'Unknown';
}

/// NFT Collection State for Database NFTs
class DatabaseNFTCollectionState {
  final bool isLoading;
  final List<DatabaseNFT> myNFTs;
  final List<DatabaseNFT> communityNFTs;
  final String? error;
  final bool isRefreshing;

  const DatabaseNFTCollectionState({
    this.isLoading = false,
    this.myNFTs = const [],
    this.communityNFTs = const [],
    this.error,
    this.isRefreshing = false,
  });

  DatabaseNFTCollectionState copyWith({
    bool? isLoading,
    List<DatabaseNFT>? myNFTs,
    List<DatabaseNFT>? communityNFTs,
    String? error,
    bool? isRefreshing,
  }) {
    return DatabaseNFTCollectionState(
      isLoading: isLoading ?? this.isLoading,
      myNFTs: myNFTs ?? this.myNFTs,
      communityNFTs: communityNFTs ?? this.communityNFTs,
      error: error ?? this.error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  Map<String, List<DatabaseNFT>> get myNFTsByEvent {
    final groups = <String, List<DatabaseNFT>>{};
    for (final nft in myNFTs) {
      final eventName = nft.eventName ?? 'Event ${nft.eventId}';
      if (!groups.containsKey(eventName)) {
        groups[eventName] = [];
      }
      groups[eventName]!.add(nft);
    }
    return groups;
  }

  Map<String, List<DatabaseNFT>> get communityNFTsByEvent {
    final groups = <String, List<DatabaseNFT>>{};
    for (final nft in communityNFTs) {
      final eventName = nft.eventName ?? 'Event ${nft.eventId}';
      if (!groups.containsKey(eventName)) {
        groups[eventName] = [];
      }
      groups[eventName]!.add(nft);
    }
    return groups;
  }
}

/// Database NFT Collection Notifier
class DatabaseNFTCollectionNotifier extends StateNotifier<DatabaseNFTCollectionState> {
  final Ref _ref;
  final DatabaseNFTService _nftService = DatabaseNFTService();

  DatabaseNFTCollectionNotifier(this._ref) : super(const DatabaseNFTCollectionState());

  /// Load NFTs for the current wallet and community
  Future<void> loadNFTs() async {
    final walletState = _ref.read(walletConnectionProvider);
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      List<DatabaseNFT> myNFTs = [];
      List<DatabaseNFT> communityNFTs = [];

      if (walletState.isConnected && walletState.walletAddress != null) {
        // Get user's claimed NFTs
        myNFTs = await _nftService.getClaimedNFTs(walletState.walletAddress!);
        
        // Get all community NFTs
        communityNFTs = await _nftService.getAllClaimedNFTs();
        
        // Remove user's NFTs from community list to avoid duplicates
        communityNFTs.removeWhere((nft) => 
            nft.claimedBy?.toLowerCase() == walletState.walletAddress!.toLowerCase());
      } else {
        // If not connected, just show community NFTs
        communityNFTs = await _nftService.getAllClaimedNFTs();
      }
      
      state = state.copyWith(
        myNFTs: myNFTs,
        communityNFTs: communityNFTs,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load NFTs: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Refresh NFTs
  Future<void> refreshNFTs() async {
    state = state.copyWith(isRefreshing: true);
    await loadNFTs();
    state = state.copyWith(isRefreshing: false);
  }
}

/// Provider for Database NFT collection state
final databaseNFTCollectionProvider = StateNotifierProvider<DatabaseNFTCollectionNotifier, DatabaseNFTCollectionState>((ref) {
  return DatabaseNFTCollectionNotifier(ref);
});

/// Updated NFT Viewer Screen
class NFTViewerScreen extends ConsumerStatefulWidget {
  const NFTViewerScreen({super.key});

  @override
  ConsumerState<NFTViewerScreen> createState() => _NFTViewerScreenState();
}

class _NFTViewerScreenState extends ConsumerState<NFTViewerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isListView = true;
  String? _lastWalletAddress;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load NFTs when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(databaseNFTCollectionProvider.notifier).loadNFTs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nftState = ref.watch(databaseNFTCollectionProvider);
    final walletState = ref.watch(walletConnectionProvider);

    // Check if wallet address changed and reload NFTs if needed
    final currentAddress = walletState.isConnected ? walletState.walletAddress : null;
    if (currentAddress != _lastWalletAddress) {
      _lastWalletAddress = currentAddress;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(databaseNFTCollectionProvider.notifier).loadNFTs();
      });
    }

    return Scaffold(
      body: Container(
        decoration: AppTheme.modernScaffoldBackground,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(walletState, nftState),
              
              // Tab Bar
              _buildTabBar(),
              
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMyNFTsTab(nftState),
                    _buildMyEventGroupsTab(nftState),
                    _buildRecentNFTsTab(nftState),
                    _buildCommunityNFTsTab(nftState),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WalletConnectionState walletState, DatabaseNFTCollectionState nftState) {
    final isConnected = walletState.isConnected && walletState.walletAddress != null;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textColor),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NFT Collection',
                      style: AppTheme.modernTitle.copyWith(
                        fontSize: 24,
                        color: AppTheme.textColor,
                      ),
                    ),
                    Text(
                      isConnected 
                          ? _getStatsText(nftState, walletState)
                          : 'Connect your wallet to view your claimed NFTs',
                      style: AppTheme.modernBodySecondary.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
         
              IconButton(
                onPressed: () {
                  setState(() {
                    _isListView = !_isListView;
                  });
                },
                
                icon: Icon(
                  _isListView ? Icons.grid_view : Icons.list,
                  color: AppTheme.accentColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(databaseNFTCollectionProvider.notifier).refreshNFTs();
                },
                icon: const Icon(
                  Icons.refresh,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: AppTheme.NFTContainerDecoration,
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        
        ),
        labelColor: AppTheme.textColor,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: AppTheme.modernButton.copyWith(fontSize: 12),
        unselectedLabelStyle: AppTheme.modernBodySecondary.copyWith(fontSize: 12),
        tabs: const [
          Tab(text: 'My NFTs'),
          Tab(text: 'By Event'),
          Tab(text: 'Recent'),
          Tab(text: 'Community'),
        ],
      ),
    );
  }

  Widget _buildMyNFTsTab(DatabaseNFTCollectionState nftState) {
    return _buildNFTContent(nftState.myNFTs, nftState);
  }

  Widget _buildMyEventGroupsTab(DatabaseNFTCollectionState nftState) {
    if (nftState.isLoading) {
      return _buildLoadingState();
    }

    if (nftState.error != null) {
      return _buildErrorState(nftState.error!);
    }

    if (nftState.myNFTs.isEmpty) {
      return _buildEmptyState(isConnected: true);
    }

    return _buildEventGroupedContent(nftState.myNFTsByEvent, nftState);
  }

  Widget _buildRecentNFTsTab(DatabaseNFTCollectionState nftState) {
    final recentNFTs = nftState.myNFTs.where((nft) {
      if (nft.claimedAt == null) return false;
      final daysSinceClaim = DateTime.now().difference(nft.claimedAt!).inDays;
      return daysSinceClaim <= 7;
    }).toList();

    return _buildNFTContent(recentNFTs, nftState);
  }

  Widget _buildCommunityNFTsTab(DatabaseNFTCollectionState nftState) {
    return _buildCommunityContent(nftState);
  }

  Widget _buildNFTContent(List<DatabaseNFT> nfts, DatabaseNFTCollectionState nftState) {
    if (nftState.isLoading) {
      return _buildLoadingState();
    }

    if (nftState.error != null) {
      return _buildErrorState(nftState.error!);
    }

    if (nfts.isEmpty) {
      final walletState = ref.watch(walletConnectionProvider);
      final isConnected = walletState.isConnected && walletState.walletAddress != null;
      return _buildEmptyState(isConnected: isConnected);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(databaseNFTCollectionProvider.notifier).refreshNFTs(),
      color: AppTheme.accentColor,
      child: _isListView
          ? _buildListView(nfts)
          : _buildGridView(nfts),
    );
  }


  Widget _buildCommunityContent(DatabaseNFTCollectionState nftState) {
    if (nftState.isLoading) {
      return _buildLoadingState();
    }

    if (nftState.error != null) {
      return _buildErrorState(nftState.error!);
    }

    if (nftState.communityNFTs.isEmpty) {
      return _buildEmptyState(isConnected: false, isCommunity: true);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(databaseNFTCollectionProvider.notifier).refreshNFTs(),
      color: AppTheme.primaryColor,
      child: _buildCommunityEventGroupedContent(nftState.communityNFTsByEvent, nftState),
    );
  }

  Widget _buildEventGroupedContent(Map<String, List<DatabaseNFT>> eventGroups, DatabaseNFTCollectionState nftState) {
    return RefreshIndicator(
      onRefresh: () => ref.read(databaseNFTCollectionProvider.notifier).refreshNFTs(),
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: eventGroups.length,
        itemBuilder: (context, index) {
          final eventName = eventGroups.keys.elementAt(index);
          final eventNFTs = eventGroups[eventName]!;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: AppTheme.modernContainerDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.event,
                          color: AppTheme.textColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventName,
                              style: AppTheme.modernSubtitle.copyWith(
                                color: AppTheme.textColor,
                              ),
                               maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${eventNFTs.length} claimed NFTs',
                              style: AppTheme.modernBodySecondary.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // NFTs Grid
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _isListView
                      ? _buildEventNFTsGrid(eventNFTs)
                      : _buildEventNFTsList(eventNFTs),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommunityEventGroupedContent(Map<String, List<DatabaseNFT>> eventGroups, DatabaseNFTCollectionState nftState) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: eventGroups.length,
      itemBuilder: (context, index) {
        final eventName = eventGroups.keys.elementAt(index);
        final eventNFTs = eventGroups[eventName]!;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: AppTheme.modernContainerDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.group,
                        color: AppTheme.textColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eventName,
                            style: AppTheme.modernSubtitle.copyWith(
                              color: AppTheme.textColor,
                            ),
                             maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${eventNFTs.length} community claims',
                            style: AppTheme.modernBodySecondary.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Community NFTs List
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildCommunityNFTsList(eventNFTs),
              ),
            ],
          ),
        );
      },
    );
  }
 // FIXED: Grid view with proper aspect ratio to prevent overflow
  Widget _buildEventNFTsGrid(List<DatabaseNFT> nfts) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75, // CHANGED from 0.8 to 0.75 to give more height and prevent overflow
      ),
      itemCount: nfts.length,
      itemBuilder: (context, index) {
        return _buildNFTCard(nfts[index]);
      },
    );
  }

  // FIXED: List view with proper constraints
  Widget _buildEventNFTsList(List<DatabaseNFT> nfts) {
    return Column( // CHANGED from ListView to Column to prevent conflicts
      children: nfts.map((nft) => Padding(
        padding: const EdgeInsets.only(bottom: 12), // Add spacing between items
        child: _buildNFTListItem(nft),
      )).toList(),
    );
  }

  // FIXED: Community NFTs list with better layout
  Widget _buildCommunityNFTsList(List<DatabaseNFT> nfts) {
    return Column( // CHANGED from ListView to Column
      children: nfts.map((nft) => Padding(
        padding: const EdgeInsets.only(bottom: 8), // Reduced spacing for community items
        child: _buildCommunityNFTListItem(nft),
      )).toList(),
    );
  }


  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: AppTheme.modernGlassEffect,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading NFTs...',
            style: AppTheme.modernBody.copyWith(
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.modernContainerDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading NFTs',
              style: AppTheme.modernTitle.copyWith(
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTheme.modernBodySecondary.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(databaseNFTCollectionProvider.notifier).loadNFTs();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required bool isConnected, bool isCommunity = false}) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.modernContainerDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TokonLogo(
              size: 80,
              showText: false,
              coinColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              isCommunity 
                  ? 'No Community NFTs' 
                  : isConnected 
                      ? 'No NFTs Found' 
                      : 'Wallet Not Connected',
              style: AppTheme.modernTitle.copyWith(
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCommunity
                  ? 'No one has claimed any bounty NFTs yet. Be the first to start exploring!'
                  : isConnected 
                      ? 'You haven\'t claimed any bounty NFTs yet. Start exploring events to claim your first NFT!'
                      : 'Connect your wallet to view your claimed bounty NFTs and explore available bounties.',
              style: AppTheme.modernBodySecondary.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/events'),
              child: Text(isConnected ? 'Explore Bounties' : 'Explore Events'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<DatabaseNFT> nfts) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: nfts.length,
      itemBuilder: (context, index) {
        return _buildNFTCard(nfts[index]);
      },
    );
  }

  Widget _buildListView(List<DatabaseNFT> nfts) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: nfts.length,
      itemBuilder: (context, index) {
        return _buildNFTListItem(nfts[index]);
      },
    );
  }


  Widget _buildNFTCard(DatabaseNFT nft) {
    return GestureDetector(
      onTap: () => _showNFTDetails(nft),
      child: Container(
        decoration: AppTheme.modernContainerDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NFT Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: AppTheme.primaryGradient,
                ),
                child: nft.hasValidImage
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          nft.formattedImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        ),
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
            
            // NFT Info - FIXED: Better spacing and text sizing
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // ADDED: Prevent overflow
                  children: [
                    Text(
                      nft.displayName,
                      style: AppTheme.modernButton.copyWith(
                        color: AppTheme.textColor,
                        fontSize: 13, // Reduced font size
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3), // Reduced spacing
                    Flexible( // ADDED: Make description flexible
                      child: Text(
                        nft.displayDescription,
                        style: AppTheme.modernBodySecondary.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 11, // Reduced font size
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    // Status and ID row
                    Row(
                      children: [
                        Flexible( // ADDED: Make status badge flexible
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reduced padding
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Claimed',
                              style: AppTheme.modernBodySecondary.copyWith(
                                color: AppTheme.successColor,
                                fontSize: 9, // Reduced font size
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4), // Reduced spacing
                        Flexible( // ADDED: Make token ID flexible
                          child: Text(
                            nft.nftTokenId != null ? '#${nft.nftTokenId}' : '#${nft.id.substring(0, 6)}', // Shorter ID
                            style: AppTheme.modernBodySecondary.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 9, // Reduced font size
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2), // Reduced spacing
                    if (nft.claimedAt != null)
                      Text(
                        'Claimed: ${_formatDate(nft.claimedAt!)}',
                        style: AppTheme.modernBodySecondary.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 8, // Reduced font size
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FIXED: List item with proper constraints
  Widget _buildNFTListItem(DatabaseNFT nft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Reduced margin
      decoration: AppTheme.modernContainerDecoration,
      child: Padding(
        padding: const EdgeInsets.all(12), // ADDED: Manual padding for better control
        child: Row(
          children: [
            // Leading image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: AppTheme.primaryGradient,
              ),
              child: nft.hasValidImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        nft.formattedImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      ),
                    )
                  : _buildPlaceholderImage(),
            ),
            const SizedBox(width: 12),
            
            // Content area - FIXED: Proper expansion and constraints
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // ADDED: Prevent overflow
                children: [
                  Text(
                    nft.displayName,
                    style: AppTheme.modernButton.copyWith(
                      color: AppTheme.textColor,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nft.displayDescription,
                    style: AppTheme.modernBodySecondary.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Status row - FIXED: Better layout
                  Wrap( // CHANGED from Row to Wrap to prevent overflow
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Claimed',
                          style: AppTheme.modernBodySecondary.copyWith(
                            color: AppTheme.successColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Text(
                        nft.nftTokenId != null ? '#${nft.nftTokenId}' : '#${nft.id.substring(0, 8)}',
                        style: AppTheme.modernBodySecondary.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      if (nft.claimedAt != null)
                        Text(
                          _formatDate(nft.claimedAt!),
                          style: AppTheme.modernBodySecondary.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
           
          
          ],
        ),
      ),
    );
  }

  // FIXED: Community NFT item with reduced congestion
  Widget _buildCommunityNFTListItem(DatabaseNFT nft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Reduced margin
      padding: const EdgeInsets.all(10), // Reduced padding
      decoration: AppTheme.modernContainerDecoration,
      child: Row(
        children: [
          // User Avatar - MADE SMALLER
          Container(
            width: 32, // Reduced from 40
            height: 32, // Reduced from 40
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _generateGradientForAddress(nft.claimedBy ?? ''),
            ),
            child: Center(
              child: Text(
                _generateInitialsFromAddress(nft.claimedBy ?? ''),
                style: AppTheme.modernButton.copyWith(
                  color: AppTheme.textColor,
                  fontSize: 11, // Reduced font size
                ),
              ),
            ),
          ),
          const SizedBox(width: 10), // Reduced spacing
          
          // NFT Thumbnail - MADE SMALLER
          Container(
            width: 40, // Reduced from 50
            height: 40, // Reduced from 50
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6), // Reduced radius
              gradient: AppTheme.primaryGradient,
            ),
            child: nft.hasValidImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      nft.formattedImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildSmallPlaceholderImage();
                      },
                    ),
                  )
                : _buildSmallPlaceholderImage(),
          ),
          const SizedBox(width: 10), // Reduced spacing
          
          // Content - FIXED: Better text sizing and spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // ADDED: Prevent overflow
              children: [
                Text(
                  nft.displayName,
                  style: AppTheme.modernButton.copyWith(
                    color: AppTheme.textColor,
                    fontSize: 12, // Reduced font size
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2), // Reduced spacing
                Text(
                  'By ${nft.shortWalletAddress}', // Shortened text
                  style: AppTheme.modernBodySecondary.copyWith(
                    color: AppTheme.accentColor,
                    fontSize: 10, // Reduced font size
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (nft.claimedAt != null) ...[
                  const SizedBox(height: 1), // Minimal spacing
                  Text(
                    _formatDate(nft.claimedAt!),
                    style: AppTheme.modernBodySecondary.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 9, // Reduced font size
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // Community badge - MADE SMALLER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reduced padding
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4), // Reduced radius
            ),
            child: Text(
              'Community',
              style: AppTheme.modernBodySecondary.copyWith(
                color: AppTheme.primaryColor,
                fontSize: 8, // Reduced font size
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.image,
          color: AppTheme.textColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSmallPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.image,
          color: AppTheme.textColor,
          size: 16,
        ),
      ),
    );
  }

  void _showNFTDetails(DatabaseNFT nft) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNFTDetailsSheet(nft),
    );
  }

  Widget _buildNFTDetailsSheet(DatabaseNFT nft) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    nft.displayName,
                    style: AppTheme.modernTitle.copyWith(
                      color: AppTheme.textColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppTheme.textColor),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NFT Image
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: nft.hasValidImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              nft.formattedImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage();
                              },
                            ),
                          )
                        : _buildPlaceholderImage(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Description
                  Text(
                    'Description',
                    style: AppTheme.modernButton.copyWith(
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nft.displayDescription,
                    style: AppTheme.modernBody.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Details
                  _buildDetailRow('Boundary ID', nft.id.substring(0, 8)),
                  _buildDetailRow('Event ID', nft.eventId.substring(0, 8)),
                  _buildDetailRow('Status', 'Claimed'),
                  _buildDetailRow('Owner', nft.shortWalletAddress),
                  _buildDetailRow('Location', nft.locationString),
                  _buildDetailRow('Radius', nft.radiusString),
                  
                  if (nft.eventName != null)
                    _buildDetailRow('Event', nft.eventName!),
                  
                  if (nft.eventCode != null)
                    _buildDetailRow('Event Code', nft.eventCode!),
                  
                  if (nft.nftTokenId != null)
                    _buildDetailRow('Token ID', '#${nft.nftTokenId}'),
                  
                  if (nft.nftContractAddress != null)
                    _buildDetailRow('Contract', '${nft.nftContractAddress!.substring(0, 6)}...${nft.nftContractAddress!.substring(nft.nftContractAddress!.length - 4)}'),
                  
                  if (nft.claimTxHash != null)
                    _buildDetailRow('Transaction', '${nft.claimTxHash!.substring(0, 6)}...${nft.claimTxHash!.substring(nft.claimTxHash!.length - 4)}'),
                  
                  if (nft.claimedAt != null)
                    _buildDetailRow('Claimed', _formatDate(nft.claimedAt!)),
                  
                  _buildDetailRow('Created', _formatDate(nft.createdAt)),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTheme.modernBodySecondary.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.modernBody.copyWith(
                color: AppTheme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getStatsText(DatabaseNFTCollectionState nftState, WalletConnectionState walletState) {
    if (nftState.myNFTs.isEmpty) {
      final displayAddress = walletState.walletAddress != null 
          ? '${walletState.walletAddress!.substring(0, 6)}...${walletState.walletAddress!.substring(walletState.walletAddress!.length - 4)}'
          : 'Unknown';
      return 'Wallet: $displayAddress • No claimed NFTs yet';
    }
    
    final totalNFTs = nftState.myNFTs.length;
    final uniqueEvents = nftState.myNFTsByEvent.keys.length;
    
    if (totalNFTs == 1) {
      return '1 NFT claimed from $uniqueEvents event${uniqueEvents == 1 ? '' : 's'}';
    } else {
      return '$totalNFTs NFTs claimed from $uniqueEvents event${uniqueEvents == 1 ? '' : 's'}';
    }
  }

  // Generate a unique gradient for each wallet address
  Gradient _generateGradientForAddress(String address) {
    final hash = address.hashCode;
    final colors = [
      AppTheme.primaryColor,
      AppTheme.primaryColor.withBlue(200),
      AppTheme.primaryColor.withRed(200),
      AppTheme.primaryColor.withGreen(200),
      Colors.purple,
      Colors.teal,
      Colors.orange,
      Colors.pink,
    ];
    
    final color1 = colors[hash % colors.length];
    final color2 = colors[(hash ~/ colors.length) % colors.length];
    
    return LinearGradient(
      colors: [color1, color2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Generate initials from wallet address
  String _generateInitialsFromAddress(String address) {
    if (address.length < 6) return 'UN';
    return address.substring(2, 4).toUpperCase();
  }
 } 