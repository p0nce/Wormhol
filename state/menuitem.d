module state.menuitem;

public
{
    import state.menuaction;
    import state.menuitem;
}

import misc.logger;
import res.settings;

class MenuItem
{
    private
    {
        MenuAction m_action;
        string m_text;
        float m_sizeFactor;
    }

    public
    {
        this(string text, MenuAction action, float sizeFactor = 1.f)
        {
            m_action = action;
            m_text = text;
            m_sizeFactor = sizeFactor;
        }

        string text()
        {
            if (action !is null)
            {
                return m_text ~ m_action.textExt;
            }
            else
            {
                return m_text;
            }
        }

        MenuAction action()
        {
            return m_action;
        }

        MenuAction action(MenuAction a)
        {
            return m_action = a;
        }

        bool enabled()
        {
            return m_action.enabled();
        }

        float sizeFactor() { return m_sizeFactor; }
        float sizeFactor(float s) { return m_sizeFactor = s; }
    }
}
