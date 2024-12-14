import { useForm } from "react-hook-form"
import { useAtom } from "jotai"
import { loginAtom, tokenAtom } from "../states"
import { Link } from "react-router-dom"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { useNavigate } from "react-router-dom"
import { zodResolver } from "@hookform/resolvers/zod"
import * as z from "zod"
import { authFetch } from "@/utils/utils"

const formSchema = z.object({
  email: z.string().email("Invalid email address"),
  password: z.string().min(6, "Password must be at least 6 characters"),
})

export default function Login() {
  const navigate = useNavigate()
  const [, setIsLoggedIn] = useAtom(loginAtom)
  const [, setToken] = useAtom(tokenAtom)

  const form = useForm({
    resolver: zodResolver(formSchema),
    defaultValues: {
      email: "",
      password: "",
    },
  })

  function loginSuccess(token) {
    setToken(token)
    setIsLoggedIn(true)
    navigate("/dashboard")
  }

  async function onSubmit(values) {
    try {
      const response = await authFetch("/api/session", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(values),
      })

      const data = await response.json()

      if (response.ok) {
        loginSuccess(data.token)
      } else {
        form.setError("root", { 
          message: data.message || "Login failed" 
        })
      }
    } catch (error) {
      form.setError("root", { 
        message: `An error occurred during login` 
      })
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-background">
      <div className="w-full max-w-sm rounded-lg border bg-card p-8 shadow-sm">
        <div className="space-y-6">
          <div className="space-y-2 text-center">
            <h1 className="text-2xl font-semibold tracking-tight">Login</h1>
            <p className="text-sm text-muted-foreground">
              Enter your credentials to access your account
            </p>
          </div>

          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
              <FormField
                control={form.control}
                name="email"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Email</FormLabel>
                    <FormControl>
                      <Input placeholder="email@example.com" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="password"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Password</FormLabel>
                    <FormControl>
                      <Input type="password" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              {form.formState.errors.root && (
                <p className="text-sm text-destructive">
                  {form.formState.errors.root.message}
                </p>
              )}

              <Button type="submit" className="w-full">
                Sign in
              </Button>
            </form>
          </Form>

          <div className="flex justify-center text-sm">
            <Link to="/register" className="underline text-gray-400 hover:text-gray-500">Don't have an account? Sign up</Link>
          </div>

        </div>
      </div>
    </div>
  )
}
