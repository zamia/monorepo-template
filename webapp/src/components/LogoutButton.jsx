import { useAtom } from 'jotai'
import { loginAtom, tokenAtom } from '@/states'
import { useNavigate } from 'react-router-dom'
import { authFetch } from '../utils/utils'
import { Link } from 'react-router-dom'

export function LogoutButton({children, className, ...props}) {
  const [, setIsLoggedIn] = useAtom(loginAtom)
  const [, setToken] = useAtom(tokenAtom)
  const navigate = useNavigate()

  const handleLogout = async () => {
    // send api request to logout
    const response = await authFetch(`/api/session`, {
      method: 'DELETE',
    })
    if (response.status === 200) {
      setIsLoggedIn(false)
      setToken('')
      navigate('/login')
    }
    else {
      console.log(response)
      navigate('/login')
    }
  }

  return (
    <Link onClick={handleLogout} className={className} {...props}>
      {children}
    </Link>
  )
} 