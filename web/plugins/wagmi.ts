import { defineNuxtPlugin } from '#app'
import { WagmiPlugin, createConfig, http } from '@wagmi/vue'
import {mainnet, sepolia} from '@wagmi/vue/chains'
import {metaMask, walletConnect, injected, safe} from '@wagmi/vue/connectors'
import {defineChain} from "viem";

const projectId = '6a6bc9ccada2df8d6c64e6bc29a2abbe';

//ANVIL
export const anvil = defineChain({
    id: 31337,
    name: 'Anvil',
    nativeCurrency: {
        name: 'Ethereum',
        symbol: 'ETH',
        decimals: 18,
    },
    rpcUrls: {
        default: {
            http: ['http://127.0.0.1:8545'],
        },
    },
})

export const wagmiConfig = createConfig({
    chains: [anvil, mainnet, sepolia],
    connectors: [
        injected(),
        walletConnect({ projectId }),
        metaMask(),
        safe(),
    ],
    ssr: true,
    transports: {
        [mainnet.id]: http(),
        [sepolia.id]: http(),
        [anvil.id]: http('http://127.0.0.1:8545'),
    },
})

declare module '@wagmi/vue' {
    interface Register {
        config: typeof wagmiConfig
    }
}

export default defineNuxtPlugin((nuxtApp) => {
    nuxtApp.vueApp.use(WagmiPlugin, { config: wagmiConfig })
})

