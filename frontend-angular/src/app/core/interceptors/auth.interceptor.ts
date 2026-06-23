import { inject } from '@angular/core';
import { HttpInterceptorFn } from '@angular/common/http';
import { AuthService } from '../services/auth.service';

/**
 * Injects X-User-ID header into every outgoing API request
 * so the backend can identify the logged-in user.
 */
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const user = auth.currentUser();

  if (user?.id) {
    const cloned = req.clone({
      setHeaders: { 'X-User-ID': user.id }
    });
    return next(cloned);
  }

  return next(req);
};
