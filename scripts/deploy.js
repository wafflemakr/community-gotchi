const Protocol = artifacts.require("Greeter");

async function main() {
  const protocol = await Protocol.new("Hello, Hardhat!");
  Protocol.setAsDeployed(protocol);

  console.log("Protocol deployed to:", protocol.address);

  const greeting = await protocol.greet();
  console.log("Current Greeting:", greeting);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
