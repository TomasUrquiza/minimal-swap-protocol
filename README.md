# CPAMM Core: Constant Product Automated Market Maker

![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.20-363636?style=for-the-badge&logo=solidity)
![Hardhat](https://img.shields.io/badge/Hardhat-v2.22-yellow?style=for-the-badge&logo=hardhat)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue?style=for-the-badge&logo=typescript)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

Una implementación rigurosa de un protocolo de intercambio descentralizado (DEX) basado en el modelo de **Producto Constante**. Este proyecto demuestra la arquitectura fundamental de las finanzas descentralizadas (DeFi), enfocándose en la precisión matemática, la eficiencia de gas y la seguridad financiera.

## 📐 Modelo Matemático

El núcleo del protocolo se rige por la invariante fundamental de la hipérbola rectangular:

$$x \cdot y = k$$

Donde $x$ e $y$ representan las reservas de los tokens en el pool y $k$ es la constante de liquidez.

### Fórmula de Intercambio (Swap) con Comisiones
Para incentivar a los proveedores de liquidez, se aplica una comisión ($\phi$) del **0.3%** en cada operación. La fórmula de salida $\Delta y$ (cantidad recibida) dada una entrada $\Delta x$, derivada para mantener la invariante, es:

$$\Delta y = \frac{y \cdot (\Delta x \cdot (1 - \phi))}{x + (\Delta x \cdot (1 - \phi))}$$

En la implementación de Solidity (usando aritmética de punto fijo con base 1000):

```solidity
// numerator = reserveOut * amountInWithFee
// denominator = (reserveIn * 1000) + amountInWithFee
amountOut = (reserveOut * (amountIn * 997)) / ((reserveIn * 1000) + (amountIn * 997));
🚀 Características TécnicasGestión de Liquidez: Funciones addLiquidity y removeLiquidity que calculan shares proporcionales basados en la oferta total.Protección de Slippage: La función swap implementa un parámetro _minAmountOut para revertir la transacción si el precio de ejecución es desfavorable (Front-running protection).Manejo de Activos: Compatibilidad total con el estándar ERC-20 (implementado con OpenZeppelin).Testing Riguroso: Suite de pruebas en TypeScript utilizando Ethers.js y Mocha para validar la lógica matemática y los casos de borde.🛠️ Stack TecnológicoCore: Solidity 0.8.20Framework de Desarrollo: HardhatTesting & Scripting: TypeScript, Ethers.js, ChaiSeguridad: OpenZeppelin Contracts⚡ Instalación y UsoPrerrequisitosNode.js (v18+)npm / yarn1. Clonar el repositorioBashgit clone [https://github.com/TomasUrquiza/cpamm-core.git](https://github.com/TomasUrquiza/cpamm-core.git)
cd cpamm-core
2. Instalar dependenciasBashnpm install
3. Ejecutar TestsEl proyecto incluye pruebas unitarias para verificar la invariante $k$ y la correcta aplicación de fees.Bashnpx hardhat test
Resultado esperado:Plaintext  CPAMM: Fees y Slippage
    ✔ Debe cobrar 0.3% de fee y proteger contra slippage
4. Compilar ContratosBashnpx hardhat compile
📂 Estructura del Proyectocontracts/CPAMM.sol: Lógica principal del AMM.contracts/MockERC20.sol: Tokens de prueba para entornos locales.test/CPAMM.test.ts: Scripts de validación matemática y funcional.Autor: Tomás Urquiza
