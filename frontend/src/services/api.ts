const STORAGE_KEY = 'portal_user';

function getUserId(): string | null {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const user = JSON.parse(raw);
    return user?.id || null;
  } catch {
    return null;
  }
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  // If the path was previously hardcoded to localhost:8080, route relative through the proxy instead.
  let url = path;
  if (url.startsWith('http://localhost:8080')) {
    url = url.replace('http://localhost:8080', '');
  }

  const headers = new Headers(options.headers || {});
  if (!(options.body instanceof FormData)) {
    headers.set('Content-Type', 'application/json');
  }

  const userId = getUserId();
  if (userId) {
    headers.set('X-User-ID', userId);
  }

  const config = {
    ...options,
    headers
  };

  const response = await fetch(url, config);

  if (!response.ok) {
    const errData = await response.json().catch(() => ({}));
    const error = new Error(errData.error || `Erro de rede: status ${response.status}`);
    (error as any).status = response.status;
    (error as any).error = errData.error || 'Erro desconhecido';
    throw error;
  }

  if (response.status === 204) {
    return {} as T;
  }

  return response.json() as Promise<T>;
}

export const api = {
  get: <T>(path: string) => request<T>(path, { method: 'GET' }),
  post: <T>(path: string, body: any) => {
    const isFormData = body instanceof FormData;
    return request<T>(path, {
      method: 'POST',
      body: isFormData ? body : JSON.stringify(body)
    });
  },
  put: <T>(path: string, body: any) => {
    const isFormData = body instanceof FormData;
    return request<T>(path, {
      method: 'PUT',
      body: isFormData ? body : JSON.stringify(body)
    });
  },
  delete: <T>(path: string) => request<T>(path, { method: 'DELETE' }),
};
export default api;
