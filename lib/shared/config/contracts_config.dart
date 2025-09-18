class ContractsConfig {
  // Contract addresses for Somnia Testnet (DEPLOYED ✅)
  static const Map<String, String> somniaTestnetContracts = {
    'EventFactory': '0xf9CF13b978A71113992De2A0373fE76d3B64B6dc',
    'BoundaryNFT': '0xbac9dBf16337cAC4b8aBAef3941615e57dB37073',
    'ClaimVerification': '0xB6Ba7b7501D5F6D71213B0f75f7b8a9eFc3e8507',
  };

  // Contract addresses for Somnia Mainnet (for future use)
  static const Map<String, String> somniaMainnetContracts = {
    'EventFactory': '0x0000000000000000000000000000000000000000',
    'BoundaryNFT': '0x0000000000000000000000000000000000000000',
    'ClaimVerification': '0x0000000000000000000000000000000000000000',
  };

 

  

  // Network configurations
  static const Map<String, Map<String, dynamic>> networkConfigs = {
    'somniaTestnet': {
      'name': 'Somnia Testnet',
      'chainId': 50312,
      'rpcUrl': 'https://dream-rpc.somnia.network',
      'nativeCurrency': 'STT',
      'blockExplorer': 'https://shannon-explorer.somnia.network/',
      'contracts': somniaTestnetContracts,
    },
    'somniaMainnet': {
      'name': 'Somnia Mainnet',
      'chainId': 5031,
      'rpcUrl': 'https://api.infra.mainnet.somnia.network/',
      'nativeCurrency': 'SOMI',
      'blockExplorer': 'https://explorer.somnia.network',
      'contracts': somniaMainnetContracts,
    },
   
    
    
  };

  // Default network
  static const String defaultNetwork = 'somniaTestnet';

  // Get contract addresses for a specific network
  static Map<String, String> getContracts(String network) {
    final networkConfig = networkConfigs[network];
    if (networkConfig == null) {
      throw Exception('Unknown network: $network');
    }
    return Map<String, String>.from(networkConfig['contracts']);
  }

  // Get network configuration
  static Map<String, dynamic> getNetworkConfig(String network) {
    final networkConfig = networkConfigs[network];
    if (networkConfig == null) {
      throw Exception('Unknown network: $network');
    }
    return Map<String, dynamic>.from(networkConfig);
  }

  // Get contract address by name and network
  static String getContractAddress(String contractName, [String? network]) {
    network ??= defaultNetwork;
    final contracts = getContracts(network);
    final address = contracts[contractName];
    if (address == null) {
      throw Exception('Contract $contractName not found for network $network');
    }
    return address;
  }

  // Check if contracts are deployed for a network
  static bool areContractsDeployed(String network) {
    try {
      final contracts = getContracts(network);
      return contracts.values.every((address) => 
        address != '0x0000000000000000000000000000000000000000' && 
        address.isNotEmpty
      );
    } catch (e) {
      return false;
    }
  }

  // Get supported networks
  static List<String> getSupportedNetworks() {
    return networkConfigs.keys.toList();
  }

  // Get network name by chain ID
  static String? getNetworkByChainId(int chainId) {
    for (final entry in networkConfigs.entries) {
      if (entry.value['chainId'] == chainId) {
        return entry.key;
      }
    }
    return null;
  }
}