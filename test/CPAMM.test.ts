import { expect } from "chai";
import { ethers } from "hardhat";

describe("CPAMM: Fees y Slippage", function () {
  it("Debe cobrar 0.3% de fee y proteger contra slippage", async function () {
    const [owner] = await ethers.getSigners();

    // 1. Despliegue (Igual que antes)
    const TokenFactory = await ethers.getContractFactory("MockERC20");
    const token0 = await TokenFactory.deploy("Token A", "TKA");
    const token1 = await TokenFactory.deploy("Token B", "TKB");
    await token0.waitForDeployment();
    await token1.waitForDeployment();

    const CPAMMFactory = await ethers.getContractFactory("CPAMM");
    const cpamm = await CPAMMFactory.deploy(token0.target, token1.target);
    await cpamm.waitForDeployment();

    // 2. Liquidez Inicial
    const amount = ethers.parseEther("1000");
    await token0.approve(cpamm.target, amount);
    await token1.approve(cpamm.target, amount);
    await cpamm.addLiquidity(amount, amount);

    // 3. Ejecutar SWAP con Fee
    const swapAmount = ethers.parseEther("100"); // 100 tokens entran
    await token0.approve(cpamm.target, swapAmount);
    
    // Cálculo esperado con FEE del 0.3%:
    // In con fee = 100 * 997 = 99700
    // Numerador = 1000 (reserva) * 99700 = 99,700,000
    // Denominador = (1000 * 1000) + 99700 = 1,099,700
    // Salida = 99,700,000 / 1,099,700 ≈ 90.6610...
    
    // Si no hubiera fee, saldrían 90.90... La diferencia se queda en el pool para los dueños.
    
    // Definimos un mínimo aceptable (Slippage protection): Aceptamos 90, pero no menos.
    const minAmountOut = ethers.parseEther("90");

    await cpamm.swap(token0.target, swapAmount, minAmountOut);

    // Verificamos el resultado exacto
    const expectedOut = ethers.parseEther("90.661098481404019277"); // Resultado pre-calculado
    expect(await cpamm.reserve1()).to.be.closeTo(ethers.parseEther("1000") - expectedOut, 1000000000n);
    
    console.log("¡Prueba exitosa! Fee cobrado y slippage verificado.");
  });
});