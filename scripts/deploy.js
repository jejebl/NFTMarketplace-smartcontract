const main = async () => {
  try {
    const NFTMarketplaceProject = await hre.ethers.getContractFactory(
      "NFTMarketplace"
    );
    const nftmarketplaceproject = await NFTMarketplaceProject.deploy();
    await nftmarketplaceproject.deployed();

    console.log("NFTMarketplaceProject deployed to:", nftmarketplaceproject.address);
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};
  
main();