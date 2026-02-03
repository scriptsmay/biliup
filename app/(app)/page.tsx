'use client'

import React from 'react'
import { Layout, Button, Empty, Typography, Space } from '@douyinfe/semi-ui'
import { IconExternalOpen, IconPlay, IconSetting } from '@douyinfe/semi-icons'
import { IllustrationSuccess, IllustrationSuccessDark } from '@douyinfe/semi-illustrations'

const { Content } = Layout
const { Title, Text } = Typography

const Home: React.FC = () => {
  return (
    <Layout style={{ height: '100%', backgroundColor: 'var(--semi-color-bg-0)' }}>
      <Content
        style={{
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          padding: '20px',
        }}
      >
        <Empty
          image={<IllustrationSuccess style={{ width: 150, height: 150 }} />}
          darkModeImage={<IllustrationSuccessDark style={{ width: 150, height: 150 }} />}
          title="欢迎使用 Biliup Web 控制台"
          description="你的全自动直播录制与上传助手已就绪。"
        >
          <div style={{ marginTop: 24, textAlign: 'center' }}>
            <Space vertical spacing="medium">
              <Title heading={4}>开始你的第一次自动化录制</Title>
              <Text type="secondary" style={{ maxWidth: 400 }}>
                您可以前往“任务管理”添加直播间链接，或者在“设置”中配置 Bilibili 账号。
              </Text>

              <Space style={{ marginTop: 16 }}>
                <Button
                  theme="solid"
                  icon={<IconPlay />}
                  onClick={() => (window.location.href = '/streamers')} // 假设你的路由逻辑
                >
                  创建任务
                </Button>
                <Button
                  theme="light"
                  icon={<IconSetting />}
                  onClick={() => (window.location.href = '/dashboard')}
                >
                  系统设置
                </Button>
                <Button
                  icon={<IconExternalOpen />}
                  onClick={() => window.open('https://biliup.github.io/biliup/', '_blank')}
                >
                  查看文档
                </Button>
              </Space>
            </Space>
          </div>
        </Empty>
      </Content>
    </Layout>
  )
}

export default Home
