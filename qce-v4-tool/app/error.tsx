'use client'

import { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { RefreshCw, ExternalLink } from 'lucide-react'

export default function Error({
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
    console.error('应用错误:', error)
  }, [error])

  const handleReport = () => {
    const title = encodeURIComponent(`[BUG] 应用错误: ${errorData.message.slice(0, 50)}`)
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
    <div className="min-h-screen bg-neutral-50 dark:bg-neutral-950 flex items-center justify-center p-6">
      <motion.div
        className="w-full max-w-[400px]"
        initial={{ opacity: 0, y: 12 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3 }}
      >
        <div className="text-center mb-6">
          <h1 className="text-xl font-semibold text-neutral-900 dark:text-neutral-100 mb-1.5">
            出了点问题
          </h1>
          <p className="text-sm text-neutral-500 dark:text-neutral-400">
            应用遇到了意外错误
          </p>
        </div>

        <div className="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-800 rounded-2xl p-5">
          <div className="bg-neutral-50 dark:bg-neutral-950 border border-neutral-200 dark:border-neutral-800 rounded-xl p-4 mb-4">
            <div className="text-xs font-medium text-neutral-500 dark:text-neutral-400 uppercase tracking-wide mb-2">
              Error
            </div>
            <div className="text-sm text-neutral-900 dark:text-neutral-100 leading-relaxed break-words">
              {errorData.message}
            </div>
            {errorData.digest && (
              <div className="text-[11px] text-neutral-400 dark:text-neutral-500 font-mono mt-3 pt-3 border-t border-neutral-200 dark:border-neutral-800">
                digest: {errorData.digest}
              </div>
            )}
          </div>

          <button
            onClick={reset}
            className="w-full flex items-center justify-center gap-2 px-4 py-3 rounded-xl bg-neutral-900 dark:bg-neutral-100 text-white dark:text-neutral-900 text-sm font-medium hover:opacity-90 transition-opacity mb-2.5"
          >
            <RefreshCw className="w-4 h-4" />
            重试
          </button>

          <button
            onClick={handleReport}
            className="w-full flex items-center justify-center gap-2 px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-700 text-neutral-600 dark:text-neutral-300 text-sm font-medium hover:bg-neutral-50 dark:hover:bg-neutral-800 transition-colors"
          >
            <ExternalLink className="w-4 h-4" />
            反馈问题
          </button>
        </div>
      </motion.div>
    </div>
  )
}
