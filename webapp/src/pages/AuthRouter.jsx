import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAtom } from "jotai";
import { loginAtom } from "../states";

const AuthRouter = () => {
  const navigate = useNavigate();
  const [isLogin, ] = useAtom(loginAtom);
  console.log(`isLogin: ${isLogin}`)

  useEffect(() => {
    if(isLogin){
      navigate("/dashboard")
    } else {
      navigate("/login")
    }
  }, []);

  return <div>Loading...</div>;
};

export default AuthRouter;