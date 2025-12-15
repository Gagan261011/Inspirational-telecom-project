import { useState, useEffect } from "react"
import { Link } from "react-router-dom"
import { motion } from "framer-motion"
import {
  CreditCard,
  Download,
  DollarSign,
  Calendar,
  CheckCircle,
  AlertCircle,
  Clock,
  Plus,
  FileText,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Separator } from "@/components/ui/separator"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Spinner } from "@/components/ui/spinner"
import { useStore } from "@/store"
import { userApi } from "@/lib/api"

interface BillingData {
  currentBalance: number
  nextBillingDate: string
  paymentMethod: string
  billingHistory: any[]
}

const statusColors = {
  PAID: "success",
  PENDING: "warning",
  OVERDUE: "destructive",
} as const

// Mock data for demonstration
const mockInvoices = [
  { id: 1, date: "2024-01-15", amount: 59.99, status: "PAID" },
  { id: 2, date: "2024-02-15", amount: 59.99, status: "PAID" },
  { id: 3, date: "2024-03-15", amount: 59.99, status: "PENDING" },
]

const mockPaymentMethods = [
  { id: 1, type: "credit", last4: "4242", brand: "Visa", expiry: "12/25", isDefault: true },
  { id: 2, type: "credit", last4: "5555", brand: "Mastercard", expiry: "08/26", isDefault: false },
]

export function BillingPage() {
  const { user } = useStore()
  
  const [billing, setBilling] = useState<BillingData | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    if (user) {
      loadBillingInfo()
    }
  }, [user])

  const loadBillingInfo = async () => {
    if (!user) return
    
    try {
      setIsLoading(true)
      const data = await userApi.getBillingHistory(user.id)
      setBilling({
        currentBalance: 59.99,
        nextBillingDate: "2024-04-15",
        paymentMethod: "Visa ending in 4242",
        billingHistory: data || mockInvoices,
      })
    } catch (error) {
      // Use mock data if API fails
      setBilling({
        currentBalance: 59.99,
        nextBillingDate: "2024-04-15",
        paymentMethod: "Visa ending in 4242",
        billingHistory: mockInvoices,
      })
    } finally {
      setIsLoading(false)
    }
  }

  if (!user) {
    return (
      <div className="container py-16 text-center">
        <p className="text-muted-foreground mb-4">Please sign in to view billing.</p>
        <Link to="/login">
          <Button variant="gradient">Sign In</Button>
        </Link>
      </div>
    )
  }

  if (isLoading) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center">
        <Spinner size="lg" />
      </div>
    )
  }

  return (
    <div className="container py-8">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-8"
      >
        <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
          Billing &{" "}
          <span className="bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
            Payments
          </span>
        </h1>
        <p className="mt-2 text-muted-foreground">
          Manage your billing information and payment methods
        </p>
      </motion.div>

      {/* Summary Cards */}
      <div className="grid md:grid-cols-3 gap-6 mb-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          <Card className="bg-gradient-to-br from-purple-600 to-pink-600 text-white border-0">
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium opacity-90">
                Current Balance
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-2">
                <DollarSign className="h-8 w-8" />
                <span className="text-3xl font-bold">
                  {billing?.currentBalance.toFixed(2)}
                </span>
              </div>
              <p className="text-sm opacity-90 mt-2">
                Due on {billing?.nextBillingDate}
              </p>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
        >
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Next Billing Date
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-2">
                <Calendar className="h-8 w-8 text-purple-600" />
                <span className="text-3xl font-bold">
                  {billing?.nextBillingDate ? new Date(billing.nextBillingDate).getDate() : "--"}
                </span>
              </div>
              <p className="text-sm text-muted-foreground mt-2">
                {billing?.nextBillingDate
                  ? new Date(billing.nextBillingDate).toLocaleDateString("en-US", {
                      month: "long",
                      year: "numeric",
                    })
                  : "Not available"}
              </p>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Payment Method
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-2">
                <CreditCard className="h-8 w-8 text-purple-600" />
                <div>
                  <p className="font-bold">Visa •••• 4242</p>
                  <p className="text-sm text-muted-foreground">Expires 12/25</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </div>

      {/* Main Content */}
      <Tabs defaultValue="invoices">
        <TabsList className="mb-6">
          <TabsTrigger value="invoices">Invoices</TabsTrigger>
          <TabsTrigger value="payment-methods">Payment Methods</TabsTrigger>
          <TabsTrigger value="subscription">Subscription</TabsTrigger>
        </TabsList>

        <TabsContent value="invoices">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Billing History</CardTitle>
                <CardDescription>
                  View and download your past invoices
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {mockInvoices.map((invoice, index) => (
                    <motion.div
                      key={invoice.id}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.1 }}
                      className="flex items-center justify-between p-4 rounded-lg bg-muted/50"
                    >
                      <div className="flex items-center gap-4">
                        <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-purple-600 to-pink-600 flex items-center justify-center">
                          <FileText className="h-5 w-5 text-white" />
                        </div>
                        <div>
                          <p className="font-medium">
                            Invoice #{invoice.id.toString().padStart(4, "0")}
                          </p>
                          <p className="text-sm text-muted-foreground">
                            {new Date(invoice.date).toLocaleDateString("en-US", {
                              year: "numeric",
                              month: "long",
                              day: "numeric",
                            })}
                          </p>
                        </div>
                      </div>
                      <div className="flex items-center gap-4">
                        <Badge
                          variant={statusColors[invoice.status as keyof typeof statusColors]}
                        >
                          {invoice.status === "PAID" && <CheckCircle className="h-3 w-3 mr-1" />}
                          {invoice.status === "PENDING" && <Clock className="h-3 w-3 mr-1" />}
                          {invoice.status === "OVERDUE" && <AlertCircle className="h-3 w-3 mr-1" />}
                          {invoice.status}
                        </Badge>
                        <span className="font-bold">${invoice.amount.toFixed(2)}</span>
                        <Button variant="ghost" size="sm">
                          <Download className="h-4 w-4" />
                        </Button>
                      </div>
                    </motion.div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </TabsContent>

        <TabsContent value="payment-methods">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <Card>
              <CardHeader className="flex flex-row items-center justify-between">
                <div>
                  <CardTitle>Payment Methods</CardTitle>
                  <CardDescription>
                    Manage your saved payment methods
                  </CardDescription>
                </div>
                <Button variant="gradient">
                  <Plus className="h-4 w-4 mr-2" />
                  Add New
                </Button>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {mockPaymentMethods.map((method, index) => (
                    <motion.div
                      key={method.id}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.1 }}
                      className={`flex items-center justify-between p-4 rounded-lg border-2 ${
                        method.isDefault ? "border-purple-600 bg-purple-50 dark:bg-purple-900/20" : "border-muted"
                      }`}
                    >
                      <div className="flex items-center gap-4">
                        <div className="w-12 h-8 rounded bg-gradient-to-br from-slate-700 to-slate-900 flex items-center justify-center">
                          <CreditCard className="h-5 w-5 text-white" />
                        </div>
                        <div>
                          <p className="font-medium flex items-center gap-2">
                            {method.brand} •••• {method.last4}
                            {method.isDefault && (
                              <Badge variant="secondary" className="text-xs">
                                Default
                              </Badge>
                            )}
                          </p>
                          <p className="text-sm text-muted-foreground">
                            Expires {method.expiry}
                          </p>
                        </div>
                      </div>
                      <div className="flex items-center gap-2">
                        {!method.isDefault && (
                          <Button variant="outline" size="sm">
                            Set Default
                          </Button>
                        )}
                        <Button variant="ghost" size="sm" className="text-destructive">
                          Remove
                        </Button>
                      </div>
                    </motion.div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </TabsContent>

        <TabsContent value="subscription">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Current Subscription</CardTitle>
                <CardDescription>
                  Your active plan and features
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="p-6 rounded-xl border-2 border-purple-600 bg-gradient-to-br from-purple-50 to-pink-50 dark:from-purple-900/20 dark:to-pink-900/20">
                  <div className="flex items-center justify-between mb-4">
                    <div>
                      <Badge variant="premium" className="mb-2">Pro Plan</Badge>
                      <h3 className="text-2xl font-bold">$59.99/month</h3>
                    </div>
                    <div className="text-right">
                      <p className="text-sm text-muted-foreground">Next renewal</p>
                      <p className="font-medium">{billing?.nextBillingDate}</p>
                    </div>
                  </div>

                  <Separator className="my-4" />

                  <div className="grid md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <p className="font-medium">Plan Features:</p>
                      <ul className="space-y-1 text-sm text-muted-foreground">
                        <li className="flex items-center gap-2">
                          <CheckCircle className="h-4 w-4 text-emerald-600" />
                          Unlimited High-Speed Data
                        </li>
                        <li className="flex items-center gap-2">
                          <CheckCircle className="h-4 w-4 text-emerald-600" />
                          Unlimited Calls & SMS
                        </li>
                        <li className="flex items-center gap-2">
                          <CheckCircle className="h-4 w-4 text-emerald-600" />
                          100+ Premium Channels
                        </li>
                        <li className="flex items-center gap-2">
                          <CheckCircle className="h-4 w-4 text-emerald-600" />
                          Priority Support
                        </li>
                      </ul>
                    </div>
                    <div className="space-y-2">
                      <p className="font-medium">Usage This Month:</p>
                      <ul className="space-y-1 text-sm text-muted-foreground">
                        <li>Data: 45.2 GB / Unlimited</li>
                        <li>Calls: 320 mins</li>
                        <li>Messages: 150</li>
                      </ul>
                    </div>
                  </div>

                  <div className="flex gap-4 mt-6">
                    <Button variant="outline">Change Plan</Button>
                    <Button variant="ghost" className="text-destructive">
                      Cancel Subscription
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </TabsContent>
      </Tabs>
    </div>
  )
}
