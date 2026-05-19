"use client"

import { useCallback, useEffect, useState } from "react"
import { Button } from "./button"
import { Input } from "./input"
import { Search, Users, Loader2, AlertCircle } from "lucide-react"

interface GroupLookupCardProps {
    /** 初始群号；通常来自搜索框里的纯数字输入。 */
    initialGroupCode?: string
    /** 点击“导出”时回调，直接打开任务向导。 */
    onStartExport: (preset: { chatType: number; peerUid: string; sessionName: string }) => void
}

const GROUP_CODE_REGEX = /^\d{4,12}$/

export function GroupLookupCard({ initialGroupCode = "", onStartExport }: GroupLookupCardProps) {
    const [groupCode, setGroupCode] = useState(initialGroupCode)
    const [groupName, setGroupName] = useState("")
    const [loading, setLoading] = useState(false)
    const [error, setError] = useState<string | null>(null)

    useEffect(() => {
        setGroupCode(initialGroupCode)
    }, [initialGroupCode])

    const submit = useCallback(async () => {
        const trimmed = groupCode.trim()
        if (!GROUP_CODE_REGEX.test(trimmed)) {
            setError("请输入 4-12 位纯数字群号")
            return
        }
        setError(null)
        setLoading(true)
        try {
            onStartExport({
                chatType: 2,
                peerUid: trimmed,
                sessionName: groupName.trim() || `群 ${trimmed}`,
            })
        } finally {
            setLoading(false)
        }
    }, [groupCode, groupName, onStartExport])

    const onKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
        if (e.key === "Enter") {
            e.preventDefault()
            void submit()
        }
    }

    return (
        <div className="mt-4 mx-auto max-w-md text-left rounded-[20px] macos-surface p-4 space-y-3">
            <div>
                <p className="text-sm font-medium text-foreground">按群号直接导出</p>
                <p className="text-xs text-muted-foreground/70 mt-1">
                    适合你只知道群号、但列表里暂时没加载出来的场景。先输入群号，再在向导里选时间范围。
                </p>
            </div>

            <div className="flex gap-2">
                <Input
                    inputMode="numeric"
                    pattern="\\d*"
                    placeholder="群号 (例如 123456789)"
                    value={groupCode}
                    onChange={(e) => setGroupCode(e.target.value)}
                    onKeyDown={onKeyDown}
                    className="flex-1 h-9 text-sm rounded-xl macos-control"
                />
                <Button
                    onClick={() => void submit()}
                    disabled={loading || !groupCode.trim()}
                    size="sm"
                    className="h-9 px-3 rounded-xl"
                >
                    {loading ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Search className="w-3.5 h-3.5" />}
                    <span className="ml-1.5">{loading ? "准备中" : "导出"}</span>
                </Button>
            </div>

            <div className="space-y-2">
                <Input
                    placeholder="群名称（可选）"
                    value={groupName}
                    onChange={(e) => setGroupName(e.target.value)}
                    className="h-9 text-sm rounded-xl macos-control"
                />
                <p className="text-[11px] leading-relaxed text-muted-foreground/60">
                    不填写时会先用“群 + 群号”作为临时名称，导出后仍可在任务列表里修改识别。
                </p>
            </div>

            {error && (
                <div className="flex items-start gap-2 text-xs text-destructive">
                    <AlertCircle className="w-3.5 h-3.5 flex-shrink-0 mt-0.5" />
                    <span>{error}</span>
                </div>
            )}

            <div className="flex items-center gap-2 rounded-xl bg-black/[0.025] px-3 py-2 text-xs text-muted-foreground dark:bg-white/[0.035]">
                <Users className="w-3.5 h-3.5" />
                <span>后续会进入导出向导，在那里选择时间范围、格式和资源选项。</span>
            </div>
        </div>
    )
}
