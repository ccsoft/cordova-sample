declare module CC {
    export interface IVungleConfig {
        orientation?: number;
        soundEnabled?: boolean;
        backButtonImmediatelyEnabled?: boolean;
        immersiveMode?: boolean;
        incentivized?: boolean;
        incentivizedUserId?: string;
        incentivizedCancelDialogTitle?: string;
        incentivizedCancelDialogBodyText?: string;
        incentivizedCancelDialogCloseButtonText?: string;
        incentivizedCancelDialogKeepWatchingButtonText?: string;
        placement?: string;
        extra1?: string;
        extra2?: string;
        extra3?: string;
        extra4?: string;
        extra5?: string;
        extra6?: string;
        extra7?: string;
        extra8?: string;
    }

    export interface IVungle {
        init(vungleid: string, config?: IVungleConfig, successcb?: () => void, errorcb?: (err: string) => void): void;
        playAd(config?: IVungleConfig, successcb?: (completed: boolean) => void, errorcb?: (err: string) => void): void;
        isVideoAvailable(successcb: (avail: boolean) => void, errorcb?: (err: string) => void): void;        
    }    
}