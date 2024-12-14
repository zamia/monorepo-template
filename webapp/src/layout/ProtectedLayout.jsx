import { useAtom } from "jotai";
import { Navigate, Outlet } from "react-router-dom";
import { loginAtom } from "../states";
import { Toaster } from "@/components/ui/toaster";

const ProtectedLayout = () => {
  const [isLogin, setIsLogin] = useAtom(loginAtom);

  if (!isLogin) {
    const loginFlag = localStorage.getItem("is_login");
    if (loginFlag === "1") {
      setIsLogin(true);
    } else {
      return <Navigate to="/login" />;
    }
  }

  return (
    <div className="body">
      <main>
        <Outlet />
        <Toaster />
      </main>
    </div>
  );
};

export default ProtectedLayout;
