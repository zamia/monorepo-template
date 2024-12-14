export async function authFetch(url, options = {}) {
  const token = localStorage.getItem("token")?.replace(/^"|"$/g, "");

  const defaultHeaders = {
    "Content-Type": "application/json",
    Authorization: token ? `Bearer ${token}` : undefined,
  };

  if (options.body instanceof FormData) {
    delete defaultHeaders["Content-Type"];
  }

  const host = options.host || import.meta.env.VITE_API_HOST;

  const response = await fetch(`${host}${url}`, {
    ...options,
    headers: {
      ...defaultHeaders,
      ...options.headers,
    },
  });
  if (response.status === 401) {
    // 跳转到login页面
    window.location.href = `/login?${location.pathname}`;
  }
  if (!response.ok) {
    const error = await response.text();
    throw new Error(error);
  }

  return response;
}

export function extract_cot_content(text) {
  // extract thinking tag and speaking tag, if they exist
  // if they don't exist, return the original text
  const thinkingMatch = text.match(/<thinking>([^]*?)<\/thinking>/s);
  const speakingMatch = text.match(/<speaking>([^]*?)<\/speaking>/s);
  if (thinkingMatch === null && speakingMatch === null) {
    return {
      thinking: "",
      speaking: text,
    };
  } else {
    return {
      thinking: thinkingMatch ? thinkingMatch[1].trim() : "",
      speaking: speakingMatch ? speakingMatch[1].trim() : "",
    };
  }
}
