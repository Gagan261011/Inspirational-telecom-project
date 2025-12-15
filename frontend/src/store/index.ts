import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export interface User {
  id: number
  email: string
  firstName: string
  lastName: string
  phone?: string
  address?: string
  city?: string
  state?: string
  zipCode?: string
  country?: string
  role: string
  active: boolean
}

export interface CartItem {
  id: number
  productId: number
  productName: string
  productImage: string
  price: number
  quantity: number
  total: number
  // Aliases for component compatibility
  name?: string
  imageUrl?: string
}

export interface Cart {
  id: number
  userId: number
  items: CartItem[]
  subtotal: number
  tax: number
  total: number
  itemCount: number
}

interface AuthState {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  setUser: (user: User, token: string) => void
  logout: () => void
}

interface CartState {
  cart: Cart | null
  setCart: (cart: Cart) => void
  clearCart: () => void
}

interface ThemeState {
  isDark: boolean
  toggleTheme: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      setUser: (user, token) =>
        set({ user, token, isAuthenticated: true }),
      logout: () =>
        set({ user: null, token: null, isAuthenticated: false }),
    }),
    {
      name: 'auth-storage',
    }
  )
)

export const useCartStore = create<CartState>()(
  persist(
    (set) => ({
      cart: null,
      setCart: (cart) => set({ cart }),
      clearCart: () => set({ cart: null }),
    }),
    {
      name: 'cart-storage',
    }
  )
)

export const useThemeStore = create<ThemeState>()(
  persist(
    (set) => ({
      isDark: false,
      toggleTheme: () =>
        set((state) => {
          const newIsDark = !state.isDark
          if (newIsDark) {
            document.documentElement.classList.add('dark')
          } else {
            document.documentElement.classList.remove('dark')
          }
          return { isDark: newIsDark }
        }),
    }),
    {
      name: 'theme-storage',
      onRehydrateStorage: () => (state) => {
        if (state?.isDark) {
          document.documentElement.classList.add('dark')
        }
      },
    }
  )
)

// Combined store hook for backwards compatibility
export function useStore() {
  const authStore = useAuthStore()
  const cartStore = useCartStore()
  const themeStore = useThemeStore()
  
  return {
    // Auth
    user: authStore.user,
    token: authStore.token,
    isAuthenticated: authStore.isAuthenticated,
    setUser: (user: User) => authStore.setUser(user, authStore.token || ''),
    setToken: (token: string) => authStore.user && authStore.setUser(authStore.user, token),
    login: authStore.setUser,
    logout: authStore.logout,
    
    // Cart
    cart: cartStore.cart,
    cartItems: cartStore.cart?.items || [],
    setCart: cartStore.setCart,
    clearCart: cartStore.clearCart,
    addToCart: (item: CartItem) => {
      const currentCart = cartStore.cart
      if (currentCart) {
        const existingItem = currentCart.items.find(i => i.productId === item.productId)
        if (existingItem) {
          existingItem.quantity += item.quantity
          existingItem.total = existingItem.price * existingItem.quantity
        } else {
          currentCart.items.push(item)
        }
        currentCart.itemCount = currentCart.items.reduce((sum, i) => sum + i.quantity, 0)
        currentCart.subtotal = currentCart.items.reduce((sum, i) => sum + i.total, 0)
        currentCart.tax = currentCart.subtotal * 0.1
        currentCart.total = currentCart.subtotal + currentCart.tax
        cartStore.setCart({...currentCart})
      } else {
        const newCart: Cart = {
          id: 0,
          userId: authStore.user?.id || 0,
          items: [item],
          subtotal: item.total,
          tax: item.total * 0.1,
          total: item.total * 1.1,
          itemCount: item.quantity,
        }
        cartStore.setCart(newCart)
      }
    },
    updateCartItem: (productId: number, quantity: number) => {
      const currentCart = cartStore.cart
      if (currentCart) {
        const item = currentCart.items.find(i => i.productId === productId)
        if (item) {
          item.quantity = quantity
          item.total = item.price * quantity
        }
        currentCart.itemCount = currentCart.items.reduce((sum, i) => sum + i.quantity, 0)
        currentCart.subtotal = currentCart.items.reduce((sum, i) => sum + i.total, 0)
        currentCart.tax = currentCart.subtotal * 0.1
        currentCart.total = currentCart.subtotal + currentCart.tax
        cartStore.setCart({...currentCart})
      }
    },
    removeFromCart: (productId: number) => {
      const currentCart = cartStore.cart
      if (currentCart) {
        currentCart.items = currentCart.items.filter(i => i.productId !== productId)
        currentCart.itemCount = currentCart.items.reduce((sum, i) => sum + i.quantity, 0)
        currentCart.subtotal = currentCart.items.reduce((sum, i) => sum + i.total, 0)
        currentCart.tax = currentCart.subtotal * 0.1
        currentCart.total = currentCart.subtotal + currentCart.tax
        cartStore.setCart({...currentCart})
      }
    },
    
    // Theme
    isDark: themeStore.isDark,
    toggleTheme: themeStore.toggleTheme,
  }
}
