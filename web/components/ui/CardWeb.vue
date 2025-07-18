<script setup lang="ts">
import {
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import {
  useAccount,
  useBalance,
  useConnect,
  useWriteContract,
  useSendTransaction,
  useReadContract
} from "@wagmi/vue";
import { fundMeContract } from '@/contracts/fundMeContract'

import { useForm } from "vee-validate";
import { Input } from "~/components/ui/input";
import { toTypedSchema } from "@vee-validate/zod";
import { z } from "zod";
import { parseEther } from "viem";
import { sepolia } from 'viem/chains';
import { publicClient } from "@/lib/publicClient";

const toast = useToast();
const { connectors, connect } = useConnect();
const { status, address } = useAccount();
const { writeContract } = useWriteContract();
const { data: hash, isPending } = useSendTransaction();
const isWithdrawing = ref(false);

const ownerQuery = ref({
  address: fundMeContract.address,
  abi: fundMeContract.abi,
  functionName: 'getOwner' as const,
  chainId: sepolia.id,
});
const { data: owner, isLoading: isOwnerLoading, refetch: refetchOwner } = useReadContract(ownerQuery);

const balanceQuery = ref({
  address: fundMeContract.address,
  chainId: sepolia.id,
});
const { data: balanceData, isLoading: isBalanceLoading, refetch: refetchBalance } = useBalance(balanceQuery);

const injectedConnector = computed(() =>
    connectors.find((c) => c.id === "injected")
);

const formSchema = toTypedSchema(z.object({
  value: z.number().positive(),
}));

const { isFieldDirty, handleSubmit } = useForm({
  validationSchema: formSchema,
});

const onSubmit = handleSubmit((values) => {
  writeContract(
    {
      address: fundMeContract.address,
      abi: fundMeContract.abi,
      functionName: 'fund',
      value: parseEther(values.value.toString())
    },
    {
      onSuccess: async (data) => {
        debugger
        toast.add({
          title: 'Aguardando Confirmação',
          description: 'Aguardando confirmação da transação na blockchain...',
          icon: 'i-heroicons-arrow-path',
          color: 'info',
        });
        await publicClient.waitForTransactionReceipt({ hash: data });
        toast.add({
          title: 'Transaction Successful',
          description: `Successfully funded contract with ${values.value} ETH`,
          icon: 'i-heroicons-check-circle',
          color: 'success',
        });
        await refreshContractData();
      },
      onError: (error) => {
        toast.add({
          title: 'Transaction Failed',
          description: error?.message || String(error) || 'Houve um erro ao processar sua transação',
          icon: 'i-heroicons-x-circle',
          color: 'error',
        });
      }
    }
  );
});

const withdraw = () => {
  isWithdrawing.value = true;
  writeContract(
    {
      address: fundMeContract.address,
      abi: fundMeContract.abi,
      functionName: 'withdraw',
      chainId: sepolia.id,
    },
    {
      onSuccess: async (data) => {
        toast.add({
          title: 'Aguardando Confirmação',
          description: 'Aguardando confirmação da transação na blockchain...',
          icon: 'i-heroicons-arrow-path',
          color: 'info',
        });
        await publicClient.waitForTransactionReceipt({ hash: data });
        toast.add({
          title: 'Withdrawal Successful',
          description: 'Successfully withdrew all funds from the contract',
          icon: 'i-heroicons-check-circle',
          color: 'success',
        });
        await refreshContractData();
        isWithdrawing.value = false;
      },
      onError: (error) => {
        toast.add({
          title: 'Withdrawal Failed',
          description: error?.message || String(error) || 'There was an error processing your withdrawal',
          icon: 'i-heroicons-x-circle',
          color: 'error',
        });
        isWithdrawing.value = false;
      }
    }
  );
}

// Function to refresh all contract data
const isRefreshing = ref(false)
const refreshContractData = async () => {
  isRefreshing.value = true
  try {
    await Promise.all([
      refetchBalance(),
      refetchOwner()
    ])
    toast.add({
      title: 'Data Refreshed',
      description: 'Contract data has been updated',
      icon: 'i-heroicons-check-circle',
      color: 'info',
    })
  } catch (error) {
    console.error('Refresh error:', error)
  } finally {
    isRefreshing.value = false
  }
}
function copyAddress() {
  if (!address.value) return;
  navigator.clipboard.writeText(address.value);
  toast.add({
    title: 'Address Copied',
    description: 'Address copied to clipboard',
    icon: 'i-heroicons-clipboard-document-check',
    color: 'info',
  });
}

const copyOwnerAddress = (owner?: string) => {
  if (!owner) return;
  navigator.clipboard.writeText(owner);
  toast.add({
    title: 'Owner Address Copied',
    description: 'Owner address copied to clipboard',
    icon: 'i-heroicons-clipboard-document-check',
    color: 'info',
  });
}

const copyTransactionHash = (hash?: string) => {
  if (!hash) return;
  navigator.clipboard.writeText(hash)
}

</script>

<template>
  <UCard class="w-full max-w-md">
    <template #header>
      <div class="flex justify-end items-center mb-2">
        <UBadge v-if="status === 'connected'" color="success">Connected</UBadge>
        <UBadge v-else color="warning">Disconnected</UBadge>
      </div>
      <div class="text-center">
        <h1 class="text-2xl font-bold">Web3 Fund Me</h1>
      </div>
    </template>

    <div class="space-y-4">
      <!-- Wallet Connection -->
      <UAlert
          v-if="status !== 'connected'"
          title="Connect your wallet to interact with the contract"
          icon="i-heroicons-exclamation-triangle"
          color="warning"
      />

      <Button
          v-if="injectedConnector && status !== 'connected'"
          @click="connect({ connector: injectedConnector, chainId: sepolia.id })"
          class="w-full"
          size="lg"
      >
            <span class="flex items-center gap-2">
              <UIcon name="i-heroicons-wallet" />
              Connect Wallet
            </span>
      </Button>

      <!-- Contract Info -->
      <div v-if="status === 'connected'" class="bg-gray-100 dark:bg-gray-800 rounded-sm p-4 space-y-2">
        <div class="flex justify-between items-center mb-2">
          <h3 class="font-medium">Contract Info</h3>
          <UButton
              icon="i-heroicons-arrow-path"
              variant="ghost"
              size="xs"
              :loading="isRefreshing"
              @click="refreshContractData"
              :disabled="isBalanceLoading || isOwnerLoading"
          >
            {{ isRefreshing ? 'Refreshing...' : 'Refresh' }}
          </UButton>
        </div>
        <div class="flex justify-between">
          <span class="text-gray-500">Address:</span>
          <div class="flex items-center gap-1">
            <span class="font-mono text-sm truncate max-w-[160px]">{{ address }}</span>
            <UTooltip text="Copy address">
              <UButton
                  icon="i-heroicons-clipboard"
                  variant="ghost"
                  size="xs"
                  @click="copyAddress"
              />
            </UTooltip>
          </div>
        </div>
        <div class="flex justify-between">
          <span class="text-gray-500">Contract Balance:</span>
          <USkeleton v-if="isBalanceLoading" class="h-5 w-20" />
          <span v-else class="font-bold">{{ balanceData?.formatted ?? '0' }} ETH</span>
        </div>
        <div class="flex justify-between">
          <span class="text-gray-500">Contract Owner:</span>
          <USkeleton v-if="isOwnerLoading" class="h-5 w-40" />
          <div v-else class="flex items-center gap-1">
            <span class="font-mono text-sm truncate max-w-[160px]">{{ owner }}</span>
            <UTooltip text="Copy owner address">
              <UButton
                  icon="i-heroicons-clipboard"
                  variant="ghost"
                  size="xs"
                  @click="copyOwnerAddress(owner)"
              />
            </UTooltip>
          </div>
        </div>
      </div>

      <!-- Funding Form -->
      <form v-if="status === 'connected'" class="space-y-4" @submit="onSubmit">
        <FormField v-slot="{ componentField }" name="value" :validate-on-blur="!isFieldDirty">
          <FormItem>
            <FormLabel>I want to contribute with...</FormLabel>
            <FormControl>
              <Input type="number" step="any" min="0.00000001" placeholder="Value in ETH" v-bind="componentField" class="w-full" />
            </FormControl>
            <FormDescription v-if="hash">
              <UTooltip text="Click to copy">
                <div @click="copyTransactionHash(hash)" class="cursor-pointer">
                  Transaction Hash: <span class="font-mono text-xs">{{ hash.substring(0, 15) }}...{{ hash.substring(hash.length - 8) }}</span>
                </div>
              </UTooltip>
            </FormDescription>
            <FormMessage />
          </FormItem>
        </FormField>
        <Button type="submit" class="w-full" :disabled="isPending">
          <UIcon v-if="isPending" name="i-heroicons-arrow-path" class="animate-spin mr-2" />
          {{ isPending ? 'Processing...' : 'Fund Contract' }}
        </Button>
      </form>
    </div>

    <template #footer>
      <div v-if="status === 'connected' && owner === address" class="text-center">
        <UDivider class="my-4" />
        <p class="text-sm text-gray-500 mb-2">Contract owner actions</p>
        <Button @click="withdraw" variant="outline" class="w-full" :disabled="isWithdrawing">
          <UIcon v-if="isWithdrawing" name="i-heroicons-arrow-path" class="animate-spin mr-2" />
          <UIcon v-else name="i-heroicons-arrow-uturn-down" class="mr-2" />
          {{ isWithdrawing ? 'Withdrawing...' : 'Withdraw All Funds' }}
        </Button>
      </div>
    </template>
  </UCard>
</template>

<style scoped>

</style>