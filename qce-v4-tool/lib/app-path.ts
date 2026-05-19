const AUTH_ROUTE_RE = /\/auth\/?$/

function normalizeRootPath(pathname: string) {
  return pathname.endsWith('/') ? pathname : `${pathname}/`
}

export function isAuthPath(pathname: string) {
  return AUTH_ROUTE_RE.test(pathname)
}

export function getAppRootPath(pathname?: string) {
  if (typeof window === 'undefined') {
    return '/'
  }

  const currentPath = pathname ?? window.location.pathname

  if (isAuthPath(currentPath)) {
    return normalizeRootPath(currentPath.replace(AUTH_ROUTE_RE, '/'))
  }

  return normalizeRootPath(currentPath)
}

export function getAuthPath(pathname?: string) {
  return `${getAppRootPath(pathname)}auth`
}
