'use client'

import { useEffect, useState } from 'react'

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  const [errorData, setErrorData] = useState({
    message: '',
    digest: '',
    stack: '',
    url: '',
    userAgent: '',
    time: ''
  })

  useEffect(() => {
    setErrorData({
      message: error.message || '未知错误',
      digest: error.digest || '',
      stack: error.stack || '',
      url: typeof window !== 'undefined' ? window.location.href : '',
      userAgent: typeof navigator !== 'undefined' ? navigator.userAgent : '',
      time: new Date().toISOString()
    })
    console.error('全局错误:', error)
  }, [error])

  const handleReport = () => {
    const title = encodeURIComponent(`[BUG] 全局错误: ${errorData.message.slice(0, 50)}`)
    const body = encodeURIComponent(`## 🐛 错误信息

\`\`\`
${errorData.message}
\`\`\`

## 📋 错误详情

- **错误摘要**: ${errorData.digest || '无'}
- **时间**: ${errorData.time}
- **URL**: ${errorData.url}

## 📜 堆栈跟踪

\`\`\`
${errorData.stack || '无'}
\`\`\`

## 💻 环境信息

- **浏览器**: ${errorData.userAgent}
- **QCE 版本**: v5.0.x

## 🔄 复现步骤

1. 
2. 
3. 

## ✨ 期望结果

应用正常运行，不出现错误。
`)
    
    window.open(
      `https://github.com/sudo-yf/qq-chat-exporter/issues/new?title=${title}&body=${body}&labels=bug`,
      '_blank'
    )
  }

  return (
    <html lang="zh-CN">
      <body style={{ margin: 0, fontFamily: 'system-ui, -apple-system, sans-serif' }}>
        <div style={{
          minHeight: '100vh',
          background: '#fafafa',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '24px'
        }}>
          <div style={{ width: '100%', maxWidth: '400px' }}>
            <div style={{ textAlign: 'center', marginBottom: '24px' }}>
              <h1 style={{ fontSize: '20px', fontWeight: 600, color: '#171717', marginBottom: '6px' }}>
                出了点问题
              </h1>
              <p style={{ fontSize: '14px', color: '#737373', margin: 0 }}>
                应用遇到了意外错误
              </p>
            </div>

            <div style={{
              background: '#fff',
              border: '1px solid #e5e5e5',
              borderRadius: '16px',
              padding: '20px'
            }}>
              <div style={{
                background: '#fafafa',
                border: '1px solid #e5e5e5',
                borderRadius: '12px',
                padding: '16px',
                marginBottom: '16px'
              }}>
                <div style={{
                  fontSize: '12px',
                  fontWeight: 500,
                  color: '#737373',
                  textTransform: 'uppercase',
                  letterSpacing: '0.5px',
                  marginBottom: '8px'
                }}>
                  Error
                </div>
                <div style={{
                  fontSize: '14px',
                  color: '#171717',
                  lineHeight: 1.5,
                  wordBreak: 'break-word'
                }}>
                  {errorData.message}
                </div>
                {errorData.digest && (
                  <div style={{
                    fontSize: '11px',
                    color: '#a3a3a3',
                    fontFamily: 'monospace',
                    marginTop: '12px',
                    paddingTop: '12px',
                    borderTop: '1px solid #e5e5e5'
                  }}>
                    digest: {errorData.digest}
                  </div>
                )}
              </div>

              <button
                onClick={reset}
                style={{
                  width: '100%',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '8px',
                  padding: '12px',
                  borderRadius: '10px',
                  background: '#171717',
                  color: '#fff',
                  fontSize: '14px',
                  fontWeight: 500,
                  border: 'none',
                  cursor: 'pointer',
                  marginBottom: '10px'
                }}
              >
                重试
              </button>

              <button
                onClick={handleReport}
                style={{
                  width: '100%',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '8px',
                  padding: '12px',
                  borderRadius: '10px',
                  background: 'transparent',
                  color: '#525252',
                  fontSize: '14px',
                  fontWeight: 500,
                  border: '1px solid #e5e5e5',
                  cursor: 'pointer'
                }}
              >
                反馈问题
              </button>
            </div>
          </div>
        </div>
      </body>
    </html>
  )
}
