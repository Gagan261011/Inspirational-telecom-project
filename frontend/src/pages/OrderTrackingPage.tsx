import { useState, useEffect } from "react"
import { useParams, Link } from "react-router-dom"
import { motion } from "framer-motion"
import {
  Package,
  Truck,
  CheckCircle2,
  Clock,
  MapPin,
  ArrowLeft,
  Phone,
  Mail,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Separator } from "@/components/ui/separator"
import { Progress } from "@/components/ui/progress"
import { Spinner } from "@/components/ui/spinner"
import { orderApi, Order } from "@/lib/api"
import { useToast } from "@/hooks/use-toast"

const trackingSteps = [
  { key: "PENDING", label: "Order Placed", icon: Clock },
  { key: "CONFIRMED", label: "Confirmed", icon: CheckCircle2 },
  { key: "SHIPPED", label: "Shipped", icon: Truck },
  { key: "DELIVERED", label: "Delivered", icon: Package },
]

const statusIndex: Record<string, number> = {
  PENDING: 0,
  CONFIRMED: 1,
  SHIPPED: 2,
  DELIVERED: 3,
  CANCELLED: -1,
}

export function OrderTrackingPage() {
  const { id } = useParams<{ id: string }>()
  const { toast } = useToast()
  
  const [order, setOrder] = useState<Order | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    if (id) {
      loadOrder()
    }
  }, [id])

  const loadOrder = async () => {
    if (!id) return
    
    try {
      setIsLoading(true)
      const data = await orderApi.getOrder(parseInt(id))
      setOrder(data)
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to load order details",
        variant: "destructive",
      })
    } finally {
      setIsLoading(false)
    }
  }

  if (isLoading) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center">
        <Spinner size="lg" />
      </div>
    )
  }

  if (!order) {
    return (
      <div className="container py-16 text-center">
        <p className="text-muted-foreground mb-4">Order not found.</p>
        <Link to="/orders">
          <Button variant="gradient">View All Orders</Button>
        </Link>
      </div>
    )
  }

  const currentStepIndex = statusIndex[order.status] ?? 0
  const progressPercent = order.status === "CANCELLED" ? 0 : ((currentStepIndex + 1) / trackingSteps.length) * 100

  return (
    <div className="container py-8">
      {/* Back Button */}
      <Link to="/orders" className="inline-flex items-center text-sm text-muted-foreground hover:text-foreground mb-6">
        <ArrowLeft className="h-4 w-4 mr-2" />
        Back to Orders
      </Link>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-8"
      >
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
              Order{" "}
              <span className="bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
                #{order.id}
              </span>
            </h1>
            <p className="mt-2 text-muted-foreground">
              Placed on {new Date(order.createdAt).toLocaleDateString("en-US", {
                weekday: "long",
                year: "numeric",
                month: "long",
                day: "numeric",
              })}
            </p>
          </div>
          <Badge
            variant={
              order.status === "DELIVERED"
                ? "success"
                : order.status === "CANCELLED"
                ? "destructive"
                : "secondary"
            }
            className="text-sm px-4 py-1"
          >
            {order.status}
          </Badge>
        </div>
      </motion.div>

      <div className="grid lg:grid-cols-3 gap-8">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-6">
          {/* Tracking Progress */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Tracking Status</CardTitle>
              </CardHeader>
              <CardContent>
                {order.status === "CANCELLED" ? (
                  <div className="text-center py-8">
                    <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-destructive/10 flex items-center justify-center">
                      <span className="text-2xl">❌</span>
                    </div>
                    <p className="text-destructive font-medium">Order Cancelled</p>
                  </div>
                ) : (
                  <>
                    <Progress value={progressPercent} className="h-2 mb-8" />
                    <div className="grid grid-cols-4 gap-4">
                      {trackingSteps.map((step, index) => {
                        const Icon = step.icon
                        const isCompleted = index <= currentStepIndex
                        const isCurrent = index === currentStepIndex
                        
                        return (
                          <div
                            key={step.key}
                            className={`text-center ${
                              isCompleted ? "text-foreground" : "text-muted-foreground"
                            }`}
                          >
                            <div
                              className={`w-12 h-12 mx-auto mb-2 rounded-full flex items-center justify-center transition-colors ${
                                isCurrent
                                  ? "bg-gradient-to-br from-purple-600 to-pink-600 text-white"
                                  : isCompleted
                                  ? "bg-emerald-100 text-emerald-600 dark:bg-emerald-900/30"
                                  : "bg-muted"
                              }`}
                            >
                              <Icon className="h-5 w-5" />
                            </div>
                            <p className="text-sm font-medium">{step.label}</p>
                            {isCompleted && (
                              <p className="text-xs text-muted-foreground">
                                {new Date(order.createdAt).toLocaleDateString()}
                              </p>
                            )}
                          </div>
                        )
                      })}
                    </div>
                  </>
                )}
              </CardContent>
            </Card>
          </motion.div>

          {/* Order Items */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Order Items</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {order.items?.map((item, index) => (
                    <div
                      key={index}
                      className="flex items-center gap-4 p-4 rounded-lg bg-muted/50"
                    >
                      <div className="w-16 h-16 rounded-lg bg-gradient-to-br from-purple-100 to-pink-100 flex items-center justify-center flex-shrink-0">
                        <span className="text-2xl">📦</span>
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="font-medium">Product #{item.productId}</p>
                        <p className="text-sm text-muted-foreground">
                          Quantity: {item.quantity}
                        </p>
                      </div>
                      <div className="text-right">
                        <p className="font-medium">${item.price.toFixed(2)}</p>
                        <p className="text-sm text-muted-foreground">
                          ${(item.price * item.quantity).toFixed(2)} total
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </div>

        {/* Sidebar */}
        <div className="lg:col-span-1 space-y-6">
          {/* Order Summary */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.3 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Order Summary</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Subtotal</span>
                  <span>${(order.totalAmount / 1.1).toFixed(2)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Tax</span>
                  <span>${(order.totalAmount - order.totalAmount / 1.1).toFixed(2)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Shipping</span>
                  <span className="text-emerald-600">Free</span>
                </div>
                <Separator />
                <div className="flex justify-between font-bold text-lg">
                  <span>Total</span>
                  <span>${order.totalAmount.toFixed(2)}</span>
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Shipping Address */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.4 }}
          >
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <MapPin className="h-5 w-5" />
                  Shipping Address
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-muted-foreground">
                  {order.shippingAddress || "Digital Delivery - No shipping required"}
                </p>
              </CardContent>
            </Card>
          </motion.div>

          {/* Need Help */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.5 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Need Help?</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <a
                  href="tel:+1-555-000-0000"
                  className="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground"
                >
                  <Phone className="h-4 w-4" />
                  +1 (555) 000-0000
                </a>
                <a
                  href="mailto:support@telecompro.com"
                  className="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground"
                >
                  <Mail className="h-4 w-4" />
                  support@telecompro.com
                </a>
                <Separator />
                <Button variant="outline" className="w-full">
                  Contact Support
                </Button>
              </CardContent>
            </Card>
          </motion.div>
        </div>
      </div>
    </div>
  )
}
