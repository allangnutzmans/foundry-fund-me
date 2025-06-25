import type { VueQueryPluginOptions } from '@tanstack/vue-query'
import { VueQueryPlugin, QueryClient} from '@tanstack/vue-query'
import { defineNuxtPlugin } from '#app'

export default defineNuxtPlugin((nuxtApp) => {
    const queryClient = new QueryClient({
        defaultOptions: {
            queries: {
                refetchOnWindowFocus: false,
            },
        },
    })
    const options: VueQueryPluginOptions = { queryClient }
    nuxtApp.vueApp.use(VueQueryPlugin, options)
})
