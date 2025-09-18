const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Starting deployment to Somnia Testnet...");
  console.log("📋 Network Configuration:");
  console.log("  - Network: Somnia Testnet");
  console.log("  - Chain ID: 50312");
  console.log("  - RPC URL: https://dream-rpc.somnia.network");
  console.log("  - Explorer: https://shannon-explorer.somnia.network/");
  console.log("  - Currency: STT");
  
  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log("👤 Deploying contracts with account:", deployer.address);
  
  // Check balance
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("💰 Account balance:", ethers.formatEther(balance), "STT");
  
  if (balance < ethers.parseEther("0.1")) {
    console.log("⚠️  WARNING: Low balance! You may need more STT for gas fees.");
    console.log("💧 Get testnet STT from: https://testnet.somnia.network/");
  }

  const deploymentResults = {};

  try {
    console.log("⛽ Using EIP-1559 gas pricing from Hardhat config");
    
    // 1. Deploy EventFactory
    console.log("\n📦 Deploying EventFactory contract...");
    const EventFactory = await ethers.getContractFactory("EventFactory");
    const eventFactory = await EventFactory.deploy();
    await eventFactory.waitForDeployment();
    
    const eventFactoryAddress = await eventFactory.getAddress();
    console.log("✅ EventFactory deployed to:", eventFactoryAddress);
    console.log("🔗 View on explorer: https://shannon-explorer.somnia.network/address/" + eventFactoryAddress);
    
    deploymentResults.EventFactory = {
      address: eventFactoryAddress,
      transactionHash: eventFactory.deploymentTransaction().hash,
      blockNumber: eventFactory.deploymentTransaction().blockNumber
    };

    // 2. Deploy BoundaryNFT
    console.log("\n📦 Deploying BoundaryNFT contract...");
    const BoundaryNFT = await ethers.getContractFactory("BoundaryNFT");
    const boundaryNFT = await BoundaryNFT.deploy(eventFactoryAddress);
    await boundaryNFT.waitForDeployment();
    
    const boundaryNFTAddress = await boundaryNFT.getAddress();
    console.log("✅ BoundaryNFT deployed to:", boundaryNFTAddress);
    console.log("🔗 View on explorer: https://shannon-explorer.somnia.network/address/" + boundaryNFTAddress);
    
    deploymentResults.BoundaryNFT = {
      address: boundaryNFTAddress,
      transactionHash: boundaryNFT.deploymentTransaction().hash,
      blockNumber: boundaryNFT.deploymentTransaction().blockNumber
    };

    // 3. Deploy ClaimVerification
    console.log("\n📦 Deploying ClaimVerification contract...");
    const ClaimVerification = await ethers.getContractFactory("ClaimVerification");
    const claimVerification = await ClaimVerification.deploy();
    await claimVerification.waitForDeployment();
    
    const claimVerificationAddress = await claimVerification.getAddress();
    console.log("✅ ClaimVerification deployed to:", claimVerificationAddress);
    console.log("🔗 View on explorer: https://shannon-explorer.somnia.network/address/" + claimVerificationAddress);
    
    deploymentResults.ClaimVerification = {
      address: claimVerificationAddress,
      transactionHash: claimVerification.deploymentTransaction().hash,
      blockNumber: claimVerification.deploymentTransaction().blockNumber
    };

    // 4. Contract relationships
    console.log("\n🔗 Contract relationships:");
    console.log("  - EventFactory: Standalone contract for event management");
    console.log("  - BoundaryNFT: Connected to EventFactory via constructor");
    console.log("  - ClaimVerification: Standalone contract for claim verification");

    // 5. Save deployment results
    const fs = require('fs');
    const path = require('path');
    
    const deploymentData = {
      network: "somniaTestnet",
      chainId: 50312,
      deployer: deployer.address,
      deploymentTime: new Date().toISOString(),
      contracts: deploymentResults
    };
    
    const deploymentPath = path.join(__dirname, '..', 'deployments', 'somnia-testnet-deployment.json');
    fs.writeFileSync(deploymentPath, JSON.stringify(deploymentData, null, 2));
    
    console.log("\n🎉 Deployment completed successfully!");
    console.log("📄 Deployment data saved to:", deploymentPath);
    
    // 6. Display summary
    console.log("\n📋 DEPLOYMENT SUMMARY:");
    console.log("=" .repeat(50));
    console.log("🌐 Network: Somnia Testnet (Chain ID: 50312)");
    console.log("👤 Deployer:", deployer.address);
    console.log("⏰ Time:", new Date().toISOString());
    console.log("");
    console.log("📦 CONTRACT ADDRESSES:");
    console.log("  EventFactory:     " + eventFactoryAddress);
    console.log("  BoundaryNFT:      " + boundaryNFTAddress);
    console.log("  ClaimVerification: " + claimVerificationAddress);
    console.log("");
    console.log("🔗 EXPLORER LINKS:");
    console.log("  EventFactory:     https://shannon-explorer.somnia.network/address/" + eventFactoryAddress);
    console.log("  BoundaryNFT:      https://shannon-explorer.somnia.network/address/" + boundaryNFTAddress);
    console.log("  ClaimVerification: https://shannon-explorer.somnia.network/address/" + claimVerificationAddress);
    console.log("");
    console.log("💡 NEXT STEPS:");
    console.log("  1. Update your Flutter app configuration with these addresses");
    console.log("  2. Test contract interactions on Somnia Testnet");
    console.log("  3. Get STT from faucet if needed: https://testnet.somnia.network/");
    console.log("=" .repeat(50));
    
  } catch (error) {
    console.error("❌ Deployment failed:", error);
    console.error("🔍 Error details:", error.message);
    
    if (error.message.includes("insufficient funds")) {
      console.log("💡 Solution: Get more STT from the faucet: https://testnet.somnia.network/");
    } else if (error.message.includes("network")) {
      console.log("💡 Solution: Check your RPC connection to Somnia Testnet");
    } else if (error.message.includes("gas")) {
      console.log("💡 Solution: Try increasing gas limit or gas price");
    }
    
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });